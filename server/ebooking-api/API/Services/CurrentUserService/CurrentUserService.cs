using System.Security.Claims;
using Authentication.Services.TokenHandlerService;

namespace Services.CurrentUserService;

/// <inheritdoc cref="ICurrentUserService"/>
public class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly ITokenHandlerService _tokenHandlerService;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor, ITokenHandlerService tokenHandlerService)
    {
        _httpContextAccessor = httpContextAccessor;
        _tokenHandlerService = tokenHandlerService;
    }

    public bool IsAuthenticated =>
        _httpContextAccessor.HttpContext?.User?.Identity?.IsAuthenticated == true;

    public Guid UserId
    {
        get
        {
            var raw = FindClaim(ClaimTypes.NameIdentifier);
            if (!Guid.TryParse(raw, out var userId))
                throw new InvalidOperationException(
                    "The token does not carry a user identifier. The token was issued before BE-2.1 — a new login is required.");

            return userId;
        }
    }

    public string Email => FindClaim(ClaimTypes.Email);

    public string Role => _httpContextAccessor.HttpContext?.User?.FindFirstValue(ClaimTypes.Role) ?? string.Empty;

    public Task<Guid> GetCustomerIdAsync() => _tokenHandlerService.GetCustomerIdAsync(UserId);

    public Task<Guid> GetPartnerIdAsync() => _tokenHandlerService.GetPartnerIdAsync(UserId);

    public Task<Guid> GetAdministratorIdAsync() => _tokenHandlerService.GetAdministratorIdAsync(UserId);

    private string FindClaim(string claimType)
    {
        var value = _httpContextAccessor.HttpContext?.User?.FindFirstValue(claimType);
        if (string.IsNullOrEmpty(value))
            // Do ovoga se dolazi samo ako endpoint nema [Authorize] - dakle greška u kodu,
            // a ne nešto što klijent može izazvati. Zato InvalidOperationException, ne
            // BusinessException: neka se vidi u logu kao kvar, ne kao neispravan zahtjev.
            throw new InvalidOperationException(
                $"The request is not authenticated, so the claim '{claimType}' does not exist. " +
                "The endpoint using ICurrentUserService is missing the [Authorize] attribute.");

        return value;
    }
}
