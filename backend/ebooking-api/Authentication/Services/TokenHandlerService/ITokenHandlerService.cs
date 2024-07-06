using Models.Domain;
namespace Authentication.Services.TokenHandlerService
{
    public interface ITokenHandlerService
    {
        public Task<string> CreateTokenAsync(User user);
        public Task<string> RefreshTokenAsync(string jwt);
        public string GetEmailFromJWT(string token);
        public Guid GetUserIdFromJWT(string token);
        public Guid GetAdministratorIdFromJWT (string token);
        public Guid GetCustomerIdFromJWT (string token);
        public Guid GetPartnerIdFromJWT(string token);
        public Task<string> CheckRole(string email);
    }
}