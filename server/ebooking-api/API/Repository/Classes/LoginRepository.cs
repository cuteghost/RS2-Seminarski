using Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Models.Constants;
using Models.Domain;
using Models.DTO.AuthDTO;
using Repository.Interfaces;
using Authentication.Services.HashService;
using System.Globalization;
using static Google.Apis.Auth.GoogleJsonWebSignature;

namespace API.Repository.Classes;

public class LoginRepository : ILoginRepository
{
    private const string SocialBirthDateFormat = "MM/dd/yyyy";

    private static readonly HttpClient Client = new();

    private readonly ApplicationDbContext _dbContext;
    private readonly IHashService _hasher;
    private readonly ICustomerRepository _customerRepository;
    private readonly ILogger<LoginRepository> _logger;

    public LoginRepository(ApplicationDbContext dbContext, IHashService hasher, ICustomerRepository customerRepository,
                           ILogger<LoginRepository> logger)
    {
        _dbContext = dbContext;
        _hasher = hasher;
        _customerRepository = customerRepository;
        _logger = logger;
    }

    public async Task<User> FacebookLogin(FacebookUserInfoResponse userInfo)
    {
        if (string.IsNullOrWhiteSpace(userInfo.Email))
            return null;

        var dbUser = await _dbContext.Users.FirstOrDefaultAsync(s => s.Email == userInfo.Email);

        var displayName = $"{userInfo.FirstName} {userInfo.LastName}".Trim();
        var image = await DownloadImage(userInfo.Picture?.Data?.Url);
        var birthDate = ParseSocialBirthDate(userInfo.birthday);

        if (dbUser == null)
        {
            var user = new User
            {
                DisplayName = string.IsNullOrWhiteSpace(displayName) ? userInfo.Email : displayName,
                Email = userInfo.Email,
                FirstName = userInfo.FirstName ?? string.Empty,
                LastName = userInfo.LastName ?? string.Empty,
                BirthDate = birthDate ?? default,
                Password = Guid.NewGuid().ToString(),
                Image = image,
                IsDeleted = false,
                SocialLink = SocialProviders.Facebook,
                SocialProvider = SocialProviders.Facebook,
            };

            if (!await _customerRepository.AddCustomer(user, new Customer()))
                return null;

            return user;
        }

        if (dbUser.IsDeleted)
            await Revive(dbUser, displayName, userInfo.FirstName, userInfo.LastName, birthDate, image, SocialProviders.Facebook);

        return dbUser;
    }

    public async Task<User> GoogleLogin(Payload payload, GoogleUserInfoResponse? userInfo)
    {
        var dbUser = await _dbContext.Users.FirstOrDefaultAsync(s => s.Email == payload.Email);

        var image = await DownloadImage(payload.Picture);
        var birthDate = ReadGoogleBirthDate(userInfo);
        var gender = ReadGoogleGender(userInfo);

        if (dbUser == null)
        {
            var userToBeCreated = new User
            {
                DisplayName = string.IsNullOrWhiteSpace(payload.Name) ? payload.Email : payload.Name,
                FirstName = payload.GivenName ?? string.Empty,
                LastName = payload.FamilyName ?? string.Empty,
                Email = payload.Email,
                Image = image,
                Gender = gender ?? Gender.Male,
                BirthDate = birthDate ?? default,
                Password = Guid.NewGuid().ToString(),
                SocialLink = SocialProviders.Google,
                SocialProvider = SocialProviders.Google,
            };

            if (!await _customerRepository.AddCustomer(userToBeCreated, new Customer()))
                return null;

            return userToBeCreated;
        }

        if (dbUser.IsDeleted)
        {
            if (gender.HasValue)
                dbUser.Gender = gender.Value;

            await Revive(dbUser, payload.Name, payload.GivenName, payload.FamilyName, birthDate, image, SocialProviders.Google);
        }

        return dbUser;
    }

    public async Task<User> Login(LoginDTO user)
    {
        var dbUser = await _dbContext.Users.AsNoTracking()
            .FirstOrDefaultAsync(s => s.Email == user.Email && !s.IsDeleted);

        // Lozinka se više ne može porediti u SQL-u: PBKDF2 zapis nosi nasumičnu so pa isti
        // tekst nikad ne daje isti heš. Provjera ide kroz IHashService.Verify.
        if (dbUser == null || string.IsNullOrEmpty(user.Password) || !_hasher.Verify(user.Password, dbUser.Password))
            return null;

        return dbUser;
    }

    private async Task Revive(User dbUser, string? displayName, string? firstName, string? lastName,
                              DateTime? birthDate, byte[]? image, string provider)
    {
        if (!string.IsNullOrWhiteSpace(displayName))
            dbUser.DisplayName = displayName.Trim();

        if (!string.IsNullOrWhiteSpace(firstName))
            dbUser.FirstName = firstName;

        if (!string.IsNullOrWhiteSpace(lastName))
            dbUser.LastName = lastName;

        if (birthDate.HasValue)
            dbUser.BirthDate = birthDate.Value;

        if (image != null)
            dbUser.Image = image;

        dbUser.Password = _hasher.Hash(Guid.NewGuid().ToString());
        dbUser.IsDeleted = false;
        dbUser.SocialLink = provider;
        dbUser.SocialProvider = provider;

        var customer = await _dbContext.Customers.FirstOrDefaultAsync(c => c.User.Id == dbUser.Id);
        if (customer != null)
            customer.IsDeleted = false;

        await _dbContext.SaveChangesAsync();
    }

    private async Task<byte[]?> DownloadImage(Uri? url)
    {
        if (url == null)
            return null;

        try
        {
            var response = await Client.GetAsync(url);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("Slika profila sa {Url} nije preuzeta, status {Status}.", url, (int)response.StatusCode);
                return null;
            }

            return await response.Content.ReadAsByteArrayAsync();
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Slika profila sa {Url} nije preuzeta.", url);
            return null;
        }
    }

    private Task<byte[]?> DownloadImage(string? url)
    {
        return Uri.TryCreate(url, UriKind.Absolute, out var parsed)
            ? DownloadImage(parsed)
            : Task.FromResult<byte[]?>(null);
    }

    private static DateTime? ParseSocialBirthDate(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw))
            return null;

        return DateTime.TryParseExact(raw, SocialBirthDateFormat, CultureInfo.InvariantCulture,
                                      DateTimeStyles.None, out var parsed)
            ? parsed
            : null;
    }

    private static DateTime? ReadGoogleBirthDate(GoogleUserInfoResponse? userInfo)
    {
        var date = userInfo?.Birthdays?.FirstOrDefault(b => b.Date != null)?.Date;
        if (date == null || date.Year < 1 || date.Month < 1 || date.Day < 1)
            return null;

        try
        {
            return new DateTime(date.Year, date.Month, date.Day);
        }
        catch (ArgumentOutOfRangeException)
        {
            return null;
        }
    }

    private static Gender? ReadGoogleGender(GoogleUserInfoResponse? userInfo)
    {
        var value = userInfo?.Genders?.FirstOrDefault()?.Value;
        if (string.IsNullOrWhiteSpace(value))
            return null;

        return string.Equals(value, "male", StringComparison.OrdinalIgnoreCase) ? Gender.Male : Gender.Female;
    }
}
