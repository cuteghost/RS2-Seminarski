using Models.DTO.AuthDTO;
using Models.Domain;
using Models.Models.Domain;
using System.IdentityModel.Tokens.Jwt;
using static Google.Apis.Auth.GoogleJsonWebSignature;

namespace Repository.Interfaces;

public interface ILoginRepository
{
    public Task<User> Login(LoginDTO user);
    public Task<User> FacebookLogin(FacebookUserInfoResponse userInfo);
    public Task<User> GoogleLogin(Payload payload, GoogleUserInfoResponse userInfo);
}