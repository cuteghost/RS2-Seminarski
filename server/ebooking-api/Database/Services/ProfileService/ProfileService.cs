using API.Exceptions;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Models.DTO.UserDTO;
using Models.DTO.UserDTO.Partner;

namespace Database.Services.ProfileService;

public class ProfileService : IProfileService
{
    private const int DisplayNameMinimum = 3;
    private const int DisplayNameMaximum = 50;
    private const int FirstNameMinimum = 3;
    private const int FirstNameMaximum = 15;
    private const int LastNameMinimum = 3;
    private const int LastNameMaximum = 30;
    private const int SocialLinkMaximum = 200;

    private readonly ApplicationDbContext _context;

    public ProfileService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<User> UpdateUserProfile(Guid userId, UserPATCH profile)
    {
        var user = await LoadUser(userId);

        Apply(user, profile);

        await _context.SaveChangesAsync();

        return user;
    }

    public async Task<User> UpdateUserByAdministrator(Guid actorUserId, Guid targetUserId, ManagedUserPATCH changes)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == targetUserId && !u.IsDeleted);
        if (user == null)
            throw new NotFoundException($"User with identifier {targetUserId} does not exist.");

        Apply(user, changes);

        if (changes.SocialLink != null)
            user.SocialLink = SocialLink(changes.SocialLink);

        if (changes.IsActive.HasValue && changes.IsActive.Value != user.IsActive)
        {
            if (targetUserId == actorUserId)
                throw new BusinessException(
                    "You cannot change the status of the account you are currently logged in with.");

            user.IsActive = changes.IsActive.Value;

            if (!user.IsActive)
                user.TokenVersion += 1;
        }

        await _context.SaveChangesAsync();

        return user;
    }

    public async Task<Partner> UpdatePartnerProfile(Guid userId, Guid partnerId, PartnerPATCH profile)
    {
        var partner = await _context.Partners
            .Include(p => p.User)
            .FirstOrDefaultAsync(p => p.Id == partnerId && !p.IsDeleted);

        if (partner == null)
            throw new NotFoundException($"Partner with identifier {partnerId} does not exist.");

        if (partner.UserId != userId)
            throw new BusinessException("You can only change your own partner data.");

        if (profile.TaxId.HasValue)
        {
            if (profile.TaxId.Value <= 0)
                throw new BusinessException("Tax ID must be a whole number greater than zero.");

            partner.TaxId = profile.TaxId.Value;
        }

        if (!string.IsNullOrWhiteSpace(profile.TaxName))
            partner.TaxName = profile.TaxName.Trim();

        if (profile.PhoneNumber.HasValue)
        {
            if (profile.PhoneNumber.Value <= 0)
                throw new BusinessException("Phone number must be a whole number greater than zero, without spaces or special characters.");

            partner.PhoneNumber = profile.PhoneNumber.Value;
        }

        if (profile.CountryId != Guid.Empty && profile.CountryId != partner.CountryId)
        {
            if (!await _context.Countries.AnyAsync(c => c.Id == profile.CountryId && !c.IsDeleted))
                throw new NotFoundException($"Country with identifier {profile.CountryId} does not exist.");

            partner.CountryId = profile.CountryId;
        }

        var user = await LoadUser(userId);
        Apply(user, profile);

        await _context.SaveChangesAsync();

        return partner;
    }

    private async Task<User> LoadUser(Guid userId)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted);
        if (user == null)
            throw new NotFoundException("The logged-in account no longer exists.");

        return user;
    }

    private static void Apply(User user, UserPATCH profile)
    {
        if (!string.IsNullOrWhiteSpace(profile.DisplayName))
            user.DisplayName = Text(profile.DisplayName, DisplayNameMinimum, DisplayNameMaximum, "Display name");

        if (!string.IsNullOrWhiteSpace(profile.FirstName))
            user.FirstName = Text(profile.FirstName, FirstNameMinimum, FirstNameMaximum, "First name");

        if (!string.IsNullOrWhiteSpace(profile.LastName))
            user.LastName = Text(profile.LastName, LastNameMinimum, LastNameMaximum, "Last name");

        if (profile.BirthDate.HasValue)
        {
            if (profile.BirthDate.Value.Date >= DateTime.UtcNow.Date)
                throw new BusinessException("Date of birth must be in the past.");

            user.BirthDate = profile.BirthDate.Value.Date;
        }

        if (profile.Gender.HasValue)
            user.Gender = (Models.Domain.Gender)profile.Gender.Value;

        if (profile.Image != null)
            user.Image = profile.Image;
    }

    private static string SocialLink(string value)
    {
        var trimmed = value.Trim();
        if (trimmed.Length > SocialLinkMaximum)
            throw new BusinessException($"Social media link may have at most {SocialLinkMaximum} characters.");

        return trimmed;
    }

    private static string Text(string value, int minimum, int maximum, string field)
    {
        var trimmed = value.Trim();
        if (trimmed.Length < minimum || trimmed.Length > maximum)
            throw new BusinessException($"{field} must have between {minimum} and {maximum} characters.");

        return trimmed;
    }
}
