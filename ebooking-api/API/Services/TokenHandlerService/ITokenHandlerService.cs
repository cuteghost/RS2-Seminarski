using Models.DTO.AuthDTO;
namespace Services.TokenHandlerService
{
    public interface ITokenHandlerService
    {
        public Task<string> CreateTokenAsync(LoginDTO user);
        public Task<string> RefreshTokenAsync(string jwt);
        public string GetEmailFromJWT(string token);
        public Guid GetAdministratorIdFromJWT (string token);
        public Guid GetCustomerIdFromJWT (string token);
        public Guid GetPartnerIdFromJWT(string token);
        public Task<int> CheckRole(string email);
    }
}