using Models.Domain;

namespace Repository.Interfaces;

public interface IUserRepository
{
    public Task<string> UpdateEmail(string email, string password, Guid userId);
    public Task<string> UpdatePassword(string oldPassword, string newPassword, Guid userId);
    public Task SetPasswordAsAdministrator(Guid actorUserId, Guid targetUserId, string newPassword);
    public Task<User> UpdateRole(Role newRole, Guid userId);
}
