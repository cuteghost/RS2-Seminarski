using Database;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Models.DTO.AuthDTO;
using Repository.Interfaces;
using Services.HashService;
using Services.TokenHandlerService;

namespace Repository.Classes;

public class UserRepository : IUserRepository
{
    private readonly ApplicationDbContext _dbContext;
    private readonly IHashService _hasher;
    private readonly ITokenHandlerService _tokenHandler;

    public UserRepository(IHashService hasher, 
                          IGenericRepository<User> userGenericRepository, 
                          ApplicationDbContext applicationDbContext, 
                          ITokenHandlerService tokenHandler)
    {
        _hasher = hasher;
        _dbContext = applicationDbContext;
        _tokenHandler = tokenHandler;
    }

    public async Task<string> UpdateEmail(string email, string password, string JWT)
    {
        var userId = _tokenHandler.GetUserIdFromJWT(JWT);
        var userToUpdate = _dbContext.Users.FirstOrDefault(u => u.Id == userId);
        if (userToUpdate == null)
        {
            return await Task.FromResult("No user");
        }
        else
        {
            if (_hasher.Hash(password) == userToUpdate.Password)
            {
                userToUpdate.Email = email;
                _dbContext.Entry(userToUpdate).State = EntityState.Modified;
                await _dbContext.SaveChangesAsync();
                var newToken = await _tokenHandler.CreateTokenAsync(userToUpdate);
                return await Task.FromResult(newToken);
            }
            else
            {
                return await Task.FromResult("Wrong password supplied");
            }
        }
    }

    public async Task<string> UpdatePassword(string oldPassword, string newPassword, string JWT)
    {
        var userId = _tokenHandler.GetUserIdFromJWT(JWT);
        var userToUpdate = _dbContext.Users.FirstOrDefault(u => u.Id == userId);
        if (userToUpdate == null)
            return await Task.FromResult("No user");
        else
        {
            if (_hasher.Hash(oldPassword) == userToUpdate.Password)
            {
                userToUpdate.Password = _hasher.Hash(newPassword);
                _dbContext.Entry(userToUpdate).State = EntityState.Modified;
                await _dbContext.SaveChangesAsync();
                var newToken = await _tokenHandler.CreateTokenAsync(userToUpdate);
                return await Task.FromResult(newToken);
            }
            else
            {
                return await Task.FromResult("Wrong password supplied");
            }
        }
    }

    public async Task<User> UpdateRole(Role newRole, string JWT)
    {
        var userId = _tokenHandler.GetUserIdFromJWT(JWT);
        var userToUpdate = _dbContext.Users.FirstOrDefault(u => u.Id == userId);
        if (userToUpdate == null)
            return null;
        else
        {
            userToUpdate.Role = newRole;
            _dbContext.Entry(userToUpdate).State = EntityState.Modified;
            await _dbContext.SaveChangesAsync();
            return userToUpdate;
        }
    }
}
