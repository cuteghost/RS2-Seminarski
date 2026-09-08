using API.Exceptions;
using Database;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Models.DTO.AuthDTO;
using Repository.Interfaces;
using Authentication.Services.HashService;
using Authentication.Services.TokenHandlerService;

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

    /// <summary>
    /// Mijenja email adresu i vraca novi token, jer stari nosi staru adresu u claimu.
    /// Ranije su se neuspjesi javljali kao magicni stringovi ("No user", "Wrong password
    /// supplied") koje je kontroler morao porediti - sada idu kao izuzeci.
    /// </summary>
    public async Task<string> UpdateEmail(string email, string password, Guid userId)
    {
        if (string.IsNullOrWhiteSpace(email))
            throw new BusinessException("Email address is required.");

        var userToUpdate = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (userToUpdate == null)
            throw new NotFoundException("The logged-in account no longer exists.");

        if (!string.IsNullOrEmpty(userToUpdate.SocialProvider))
            throw new BusinessException(
                $"This account is linked to a {userToUpdate.SocialProvider} account. The email address is changed with {userToUpdate.SocialProvider}, not in the app.");

        if (!_hasher.Verify(password, userToUpdate.Password))
            throw new BusinessException("The current password is incorrect.");

        if (await _dbContext.Users.AnyAsync(u => u.Email == email && u.Id != userId))
            throw new BusinessException("An account with that email address already exists.");

        userToUpdate.Email = email;
        _dbContext.Entry(userToUpdate).State = EntityState.Modified;
        await _dbContext.SaveChangesAsync();

        return await _tokenHandler.CreateTokenAsync(userToUpdate);
    }

    public async Task<string> UpdatePassword(string oldPassword, string newPassword, Guid userId)
    {
        if (string.IsNullOrWhiteSpace(newPassword))
            throw new BusinessException("The new password is required and must not be empty.");

        var userToUpdate = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (userToUpdate == null)
            throw new NotFoundException("The logged-in account no longer exists.");

        if (!string.IsNullOrEmpty(userToUpdate.SocialProvider))
            throw new BusinessException(
                $"This account is linked to a {userToUpdate.SocialProvider} account. The password is changed with {userToUpdate.SocialProvider}, not in the app.");

        if (!_hasher.Verify(oldPassword, userToUpdate.Password))
            throw new BusinessException("The current password is incorrect.");

        userToUpdate.Password = _hasher.Hash(newPassword);
        userToUpdate.TokenVersion += 1;
        _dbContext.Entry(userToUpdate).State = EntityState.Modified;
        await _dbContext.SaveChangesAsync();

        return await _tokenHandler.CreateTokenAsync(userToUpdate);
    }

    public async Task SetPasswordAsAdministrator(Guid actorUserId, Guid targetUserId, string newPassword)
    {
        if (targetUserId == actorUserId)
            throw new BusinessException(
                "Your own password is changed through the password update, with confirmation of the current password.");

        if (string.IsNullOrWhiteSpace(newPassword))
            throw new BusinessException("The new password is required and must not be empty.");

        var userToUpdate = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == targetUserId && !u.IsDeleted);
        if (userToUpdate == null)
            throw new NotFoundException($"User with identifier {targetUserId} does not exist.");

        userToUpdate.Password = _hasher.Hash(newPassword);
        userToUpdate.TokenVersion += 1;
        _dbContext.Entry(userToUpdate).State = EntityState.Modified;
        await _dbContext.SaveChangesAsync();
    }

    public async Task<User> UpdateRole(Role newRole, Guid userId)
    {
        var userToUpdate = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId);
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
