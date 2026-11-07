namespace Services.PasswordResetService;

public interface IPasswordResetService
{
    Task RequestReset(string email);

    Task ResetPassword(string email, string code, string newPassword);
}
