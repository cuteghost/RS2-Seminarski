using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Models.Domain;
using Models.DTO.AuthDTO;
using Database;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace Services.TokenHandlerService;

public class TokenHandlerService : ITokenHandlerService
{
    private readonly IConfiguration _configuration;
    private readonly ApplicationDbContext _dbContext;

    public TokenHandlerService(IConfiguration configuration, ApplicationDbContext dbContext)
    {
        this._configuration = configuration;
        this._dbContext = dbContext;
    }
    public async Task<string> CreateTokenAsync(User user)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JWT:key"]));
        var role = await CheckRole(user.Email);
        if (role == "") return null;
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, role)
        };
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            _configuration["Jwt:Issuer"],
            _configuration["Jwt:Audience"],
            claims,
            expires: DateTime.Now.AddMinutes(15),
            signingCredentials: credentials
            );
        return await Task.FromResult(new JwtSecurityTokenHandler().WriteToken(token));
        
    }
    public async Task<string> RefreshTokenAsync(string jwt)
    {
        var email = GetEmailFromJWT(jwt);
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JWT:key"]));
        var role = await CheckRole(email);
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.Email, email),
            new Claim(ClaimTypes.Role, role)
        };
        Console.Write(role.ToString());
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            _configuration["Jwt:Issuer"],
            _configuration["Jwt:Audience"],
            claims,
            expires: DateTime.Now.AddMinutes(15),
            signingCredentials: credentials
            );
        return await Task.FromResult(new JwtSecurityTokenHandler().WriteToken(token));
    }

    public string GetEmailFromJWT(string token)
    {
        token = token.Remove(0,7);
        var handler = new JwtSecurityTokenHandler();
        var jwtAuth = handler.ReadJwtToken(token);
        var tokenEmail = jwtAuth.Claims.First(c => c.Type == ClaimTypes.Email).Value;
        return tokenEmail;
    }

    public Guid GetAdministratorIdFromJWT(string token)
    { 
        var email = GetEmailFromJWT(token);
        var query = from administrators in _dbContext.Administrators
                join user in _dbContext.Users on administrators.User.Email equals user.Email
                where email == user.Email
                select  administrators.Id;
         return query.FirstOrDefault();
    }
    public Guid GetCustomerIdFromJWT(string token)
    {
        var email = GetEmailFromJWT(token);
        var query = from customer in _dbContext.Customers
                join user in _dbContext.Users on customer.User.Email equals user.Email
                where email == user.Email
                select customer.Id;
         return query.FirstOrDefault();
    }
    
    public Guid GetPartnerIdFromJWT(string token)
    {
        var email = GetEmailFromJWT(token);
        var query = from partner in _dbContext.Partners
                    join user in _dbContext.Users on partner.User.Email equals user.Email
                    where email == user.Email
                    select partner.Id;
        return query.FirstOrDefault();
    }

    public async Task<string> CheckRole(string email)
    {
        var administrators = await _dbContext.Administrators.Include(s => s.User).AsNoTracking().ToListAsync();
        var partners = await _dbContext.Partners.Include(s => s.User).AsNoTracking().ToListAsync();
        var customers = await _dbContext.Customers.Include(s => s.User).AsNoTracking().ToListAsync();

        if (administrators.Any(a => a.User.Email == email)) return "Administrator";
        if (partners.Any(p => p.User.Email == email)) return "Partner";
        if (customers.Any(c => c.User.Email == email)) return "Customer";

        return "";
    }

    public Guid GetUserIdFromJWT(string token)
    {
        var email = GetEmailFromJWT(token);
        var query = from user in _dbContext.Users
                    where email == user.Email
                    select user.Id;
        return query.FirstOrDefault();
    }
}