using Models.DTO.AuthDTO;
using Models.Domain;

namespace Repository.Interfaces;

public interface ILoginRepository
{
    public Task<User> Login(LoginDTO user);
}