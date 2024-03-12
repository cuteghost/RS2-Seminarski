using Models.DTO.AuthDTO;
namespace Services.TokenHandlerService
{
    public interface ITokenHandlerService
    {
        public Task<string> CreateTokenAsync(LoginDTO user);
        public Task<string> RefreshTokenAsync(string jwt);
        public string GetEmailFromJWT(string token);
        public long GetAdministratorIdFromJWT (string token);
        public long GetCustomerIdFromJWT (string token);
        public long GetPartnerIdFromJWT(string token);
        public Task<int> CheckRole(string email);
    }
}