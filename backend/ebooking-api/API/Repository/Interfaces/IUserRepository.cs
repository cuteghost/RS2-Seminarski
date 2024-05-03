using Models.Domain;

namespace Repository.Interfaces;

public interface IUserRepository
{
    public Task<string> UpdateEmail(string email, string password, string JWT);
    public Task<string> UpdatePassword(string oldPassword, string newPassword, string JWT);
    public Task<User> UpdateRole(Role newRole, string JWT);
}
