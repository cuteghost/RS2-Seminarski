using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Models.Domain;
using Database;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Models.Constants;

namespace Authentication.Services.TokenHandlerService;

public class TokenHandlerService : ITokenHandlerService
{
    private const int LoginTokenLifetimeInDays = 30;
    private const int RefreshedTokenLifetimeInMinutes = 15;
    private const int PaymentTicketLifetimeInMinutes = 15;
    private const string BearerPrefix = "Bearer ";

    public const string TokenVersionClaim = "tv";
    public const string PurposeClaim = "pur";
    public const string ReservationClaim = "rid";
    public const string PaymentPurpose = "payment";

    private readonly IConfiguration _configuration;
    private readonly ApplicationDbContext _dbContext;

    public TokenHandlerService(IConfiguration configuration, ApplicationDbContext dbContext)
    {
        _configuration = configuration;
        _dbContext = dbContext;
    }

    public async Task<string> CreateTokenAsync(User user)
    {
        var role = await CheckRole(user.Id);
        if (role == string.Empty) return null;

        var version = await ReadTokenVersion(user.Id);

        return BuildToken(user.Id, user.Email, role, version, TimeSpan.FromDays(LoginTokenLifetimeInDays));
    }

    public async Task<string> RefreshTokenAsync(Guid userId)
    {
        var user = await _dbContext.Users.AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted);
        if (user == null) return null;

        var role = await CheckRole(userId);
        if (role == string.Empty) return null;

        return BuildToken(user.Id, user.Email, role, user.TokenVersion, TimeSpan.FromMinutes(RefreshedTokenLifetimeInMinutes));
    }

    public async Task<string> CreatePaymentTicketAsync(Guid userId, Guid reservationId)
    {
        var user = await _dbContext.Users.AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted);
        if (user == null) return null;

        var role = await CheckRole(userId);
        if (role == string.Empty) return null;

        return BuildToken(user.Id, user.Email, role, user.TokenVersion,
            TimeSpan.FromMinutes(PaymentTicketLifetimeInMinutes),
            new Claim(PurposeClaim, PaymentPurpose),
            new Claim(ReservationClaim, reservationId.ToString()));
    }

    public string GetEmailFromJWT(string token)
    {
        return ReadToken(token).Claims.First(c => c.Type == ClaimTypes.Email).Value;
    }

    public Guid GetUserIdFromJWT(string token)
    {
        var claims = ReadToken(token).Claims;

        // Tokeni izdati od BE-2.1 nose userId kao claim, pa upit prema bazi nije potreban.
        var idClaim = claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier || c.Type == JwtRegisteredClaimNames.NameId);
        if (idClaim != null && Guid.TryParse(idClaim.Value, out var userId))
            return userId;

        // Rezerva za tokene izdate ranije: SignalR veza iz Messengera ne bi smjela pući
        // samo zato što korisnik nije stigao da se ponovo prijavi.
        var email = claims.First(c => c.Type == ClaimTypes.Email).Value;
        return _dbContext.Users
            .Where(u => u.Email == email)
            .Select(u => u.Id)
            .FirstOrDefault();
    }

    public async Task<Guid> GetAdministratorIdAsync(Guid userId)
    {
        return await _dbContext.Administrators
            .Where(administrator => administrator.User.Id == userId && !administrator.IsDeleted)
            .Select(administrator => administrator.Id)
            .FirstOrDefaultAsync();
    }

    public async Task<Guid> GetCustomerIdAsync(Guid userId)
    {
        return await _dbContext.Customers
            .Where(customer => customer.User.Id == userId && !customer.IsDeleted)
            .Select(customer => customer.Id)
            .FirstOrDefaultAsync();
    }

    public async Task<Guid> GetPartnerIdAsync(Guid userId)
    {
        return await _dbContext.Partners
            .Where(partner => partner.User.Id == userId && !partner.IsDeleted)
            .Select(partner => partner.Id)
            .FirstOrDefaultAsync();
    }

    /// <summary>
    /// Uloga se izvodi iz toga u kojoj tabeli korisnik postoji. Ranije su se sve tri tabele
    /// učitavale u memoriju pa filtrirale u C#-u; sada su to tri <c>AnyAsync</c> upita.
    /// </summary>
    public async Task<string> CheckRole(Guid userId)
    {
        if (await _dbContext.Administrators.AnyAsync(a => a.User.Id == userId && !a.IsDeleted))
            return Roles.Administrator;

        if (await _dbContext.Partners.AnyAsync(p => p.User.Id == userId && !p.IsDeleted))
            return Roles.Partner;

        if (await _dbContext.Customers.AnyAsync(c => c.User.Id == userId && !c.IsDeleted))
            return Roles.Customer;

        return string.Empty;
    }

    public async Task InvalidateTokens(Guid userId)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (user == null)
            return;

        user.TokenVersion += 1;
        await _dbContext.SaveChangesAsync();
    }

    public async Task<bool> IsTokenVersionValid(Guid userId, int version)
    {
        var current = await _dbContext.Users.AsNoTracking()
            .Where(u => u.Id == userId && !u.IsDeleted)
            .Select(u => (int?)u.TokenVersion)
            .FirstOrDefaultAsync();

        return current != null && current.Value == version;
    }

    private async Task<int> ReadTokenVersion(Guid userId)
    {
        return await _dbContext.Users.AsNoTracking()
            .Where(u => u.Id == userId)
            .Select(u => u.TokenVersion)
            .FirstOrDefaultAsync();
    }

    private string BuildToken(Guid userId, string email, string role, int tokenVersion, TimeSpan lifetime, params Claim[] extraClaims)
    {
        // JWT_KEY se učitava iz istoimene varijable okruženja pri pokretanju (vidi API/Program.cs).
        var rawKey = _configuration["JWT:key"]
            ?? throw new InvalidOperationException("JWT:key is not configured. Set the JWT_KEY environment variable.");

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, userId.ToString()),
            new(ClaimTypes.Email, email),
            new(ClaimTypes.Role, role),
            new(TokenVersionClaim, tokenVersion.ToString()),
        };

        claims.AddRange(extraClaims);

        var credentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(rawKey)), SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            _configuration["Jwt:Issuer"],
            _configuration["Jwt:Audience"],
            claims,
            // UtcNow, a ne Now: JwtSecurityToken exp tumači kao UTC, pa je lokalno vrijeme
            // pomjeralo istek tokena za vrijednost vremenske zone.
            expires: DateTime.UtcNow.Add(lifetime),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static JwtSecurityToken ReadToken(string token)
    {
        if (token.StartsWith(BearerPrefix, StringComparison.OrdinalIgnoreCase))
            token = token[BearerPrefix.Length..];

        return new JwtSecurityTokenHandler().ReadJwtToken(token);
    }
}
