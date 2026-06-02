namespace Database.Services.AccountService;

public interface IAccountService
{
    Task DeleteOwnAccount(Guid userId);

    Task DeleteUserByAdministrator(Guid actorUserId, Guid targetUserId);
}
