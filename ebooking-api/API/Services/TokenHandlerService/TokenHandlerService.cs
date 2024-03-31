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
    public async Task<string> CreateTokenAsync(LoginDTO user)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JWT:key"]));
        var role = CheckRole(user.Email);
        var claims = new List<Claim>();
        claims.Add(new Claim(ClaimTypes.Email, user.Email));
        claims.Add(new Claim(ClaimTypes.Role, role.ToString()));
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
    public async Task<string> RefreshTokenAsync(string jwt)
    {
        var email = GetEmailFromJWT(jwt);
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JWT:key"]));
        var role = CheckRole(email);
        var claims = new List<Claim>();
        claims.Add(new Claim(ClaimTypes.Email, email));
        claims.Add(new Claim(ClaimTypes.Role, role.ToString()));
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

    public async Task<int> CheckRole(string email)
    {
        var a = await _dbContext.Administrators.Include(s => s.User).Where(u => u.User.Email == email).AsNoTracking().FirstOrDefaultAsync();
        var s = await _dbContext.Partners.Include(s => s.User).Where(u => u.User.Email == email).AsNoTracking().FirstOrDefaultAsync();
        var b = await _dbContext.Customers.Include(s => s.User).Where(u => u.User.Email == email).AsNoTracking().FirstOrDefaultAsync();
        if (a != null) return 0;
        if (s != null) return 1;
        if (b != null) return 2;
        return -1;
    }
}