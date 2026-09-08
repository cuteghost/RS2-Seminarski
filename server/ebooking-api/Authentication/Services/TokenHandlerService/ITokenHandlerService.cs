using Models.Domain;
namespace Authentication.Services.TokenHandlerService
{
    public interface ITokenHandlerService
    {
        Task<string> CreateTokenAsync(User user);

        /// <summary>Izdaje novi token za već prijavljenog korisnika. Prima <c>userId</c>, ne token.</summary>
        Task<string> RefreshTokenAsync(Guid userId);

        Task<string> CreatePaymentTicketAsync(Guid userId, Guid reservationId);

        string GetEmailFromJWT(string token);

        /// <summary>
        /// Čita <c>userId</c> iz tokena. Koristi ga SignalR hub u <c>Messenger/</c>, gdje nema
        /// <c>HttpContext</c>-a; u API projektu ide <c>ICurrentUserService.UserId</c>.
        /// </summary>
        Guid GetUserIdFromJWT(string token);

        Task<Guid> GetAdministratorIdAsync(Guid userId);
        Task<Guid> GetCustomerIdAsync(Guid userId);
        Task<Guid> GetPartnerIdAsync(Guid userId);

        Task<string> CheckRole(Guid userId);

        Task InvalidateTokens(Guid userId);

        Task<bool> IsTokenVersionValid(Guid userId, int version);
    }
}
