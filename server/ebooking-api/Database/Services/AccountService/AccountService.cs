using API.Exceptions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Models.Domain;

namespace Database.Services.AccountService;

public class AccountService : IAccountService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<AccountService> _logger;

    public AccountService(ApplicationDbContext context, ILogger<AccountService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task DeleteOwnAccount(Guid userId)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted);
        if (user == null)
            throw new NotFoundException("The logged-in account no longer exists.");

        if (await _context.Administrators.AnyAsync(a => a.User.Id == userId && !a.IsDeleted))
            throw new BusinessException(
                "Administrator accounts cannot be deleted from the application. Please contact another administrator.");

        await EnsureNoOpenReservations(userId);

        await using var transaction = await _context.Database.BeginTransactionAsync();

        var closure = await CloseRoleRows(userId);
        if (!closure.WasCustomer && !closure.WasPartner)
            throw new NotFoundException(
                "The logged-in account is not registered as either a customer or a partner, so it cannot be deleted.");

        user.IsDeleted = true;
        user.TokenVersion += 1;

        await _context.SaveChangesAsync();
        await transaction.CommitAsync();

        _logger.LogInformation(
            "Nalog {UserId} je obrisan na vlastiti zahtjev. Kupac: {IsCustomer}, partner: {IsPartner}, zatvorenih smještaja: {Accommodations}.",
            userId, closure.WasCustomer, closure.WasPartner, closure.ClosedAccommodations);
    }

    public async Task DeleteUserByAdministrator(Guid actorUserId, Guid targetUserId)
    {
        if (targetUserId == actorUserId)
            throw new BusinessException("You cannot delete the account you are currently logged in with.");

        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == targetUserId && !u.IsDeleted);
        if (user == null)
            throw new NotFoundException($"User with identifier {targetUserId} does not exist.");

        await EnsureNoOpenReservations(targetUserId);

        await using var transaction = await _context.Database.BeginTransactionAsync();

        var closure = await CloseRoleRows(targetUserId);

        user.IsDeleted = true;
        user.TokenVersion += 1;

        await _context.SaveChangesAsync();
        await transaction.CommitAsync();

        _logger.LogInformation(
            "Administrator {ActorId} je obrisao nalog {UserId}. Kupac: {IsCustomer}, partner: {IsPartner}, administrator: {IsAdministrator}, zatvorenih smještaja: {Accommodations}.",
            actorUserId, targetUserId, closure.WasCustomer, closure.WasPartner, closure.WasAdministrator, closure.ClosedAccommodations);
    }

    private async Task EnsureNoOpenReservations(Guid userId)
    {
        var now = DateTime.UtcNow;

        var customerId = await _context.Customers
            .Where(c => c.User.Id == userId && !c.IsDeleted)
            .Select(c => (Guid?)c.Id)
            .FirstOrDefaultAsync();

        if (customerId.HasValue)
        {
            var open = await _context.Reservations
                .Where(r => !r.IsDeleted)
                .CountAsync(ReservationPolicy.BlocksCustomerClosure(customerId.Value, now));

            if (open > 0)
                throw new BusinessException(
                    $"The account cannot be deleted while it has pending or confirmed reservations that are ongoing or upcoming (total: {open}). Cancel them or wait until the stays are over.");
        }

        var partnerId = await _context.Partners
            .Where(p => p.User!.Id == userId && !p.IsDeleted)
            .Select(p => (Guid?)p.Id)
            .FirstOrDefaultAsync();

        if (partnerId.HasValue)
        {
            var open = await _context.Reservations
                .Where(r => !r.IsDeleted)
                .CountAsync(ReservationPolicy.BlocksPartnerClosure(partnerId.Value, now));

            if (open > 0)
                throw new BusinessException(
                    $"The account cannot be deleted while its accommodations have pending or confirmed reservations that are ongoing or upcoming (total: {open}). Resolve those reservations first.");
        }
    }

    private async Task<(bool WasCustomer, bool WasPartner, bool WasAdministrator, int ClosedAccommodations)> CloseRoleRows(Guid userId)
    {
        var customer = await _context.Customers.FirstOrDefaultAsync(c => c.User.Id == userId && !c.IsDeleted);
        if (customer != null)
            customer.IsDeleted = true;

        var administrator = await _context.Administrators.FirstOrDefaultAsync(a => a.User.Id == userId && !a.IsDeleted);
        if (administrator != null)
            administrator.IsDeleted = true;

        var partner = await _context.Partners.FirstOrDefaultAsync(p => p.User.Id == userId && !p.IsDeleted);
        if (partner == null)
            return (customer != null, false, administrator != null, 0);

        partner.IsDeleted = true;

        var accommodations = await _context.Accommodations
            .Where(a => a.OwnerId == partner.Id && !a.IsDeleted)
            .ToListAsync();

        foreach (var accommodation in accommodations)
            accommodation.IsDeleted = true;

        return (customer != null, true, administrator != null, accommodations.Count);
    }
}
