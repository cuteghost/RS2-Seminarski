using Database;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Models.DTO.AuthDTO;
using Repository.Interfaces;
using Services.HashService;

namespace API.Repository.Classes;

public class LoginRepository : ILoginRepository
{
    private readonly ApplicationDbContext _dbContext;
    private readonly IHashService _hasher;
    public LoginRepository(ApplicationDbContext dbContext, IHashService hasher)
    {
        _dbContext = dbContext;
        _hasher = hasher;
    }
    public async Task<User> Login(LoginDTO user)
    {
        user.Password = _hasher.Hash(user.Password);
        var _user = await _dbContext.Users.AsNoTracking().Where(s => s.Email == user.Email && s.Password == user.Password).FirstOrDefaultAsync();
        if (_user != null)
            return _user;

        return null;
    }
}
