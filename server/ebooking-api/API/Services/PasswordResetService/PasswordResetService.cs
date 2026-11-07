using System.Security.Cryptography;
using API.Exceptions;
using Authentication.Services.HashService;
using Database;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Services.RabbitMQService;

namespace Services.PasswordResetService;

public class PasswordResetService : IPasswordResetService
{
    public const int CodeLength = 6;
    public const int MinimumPasswordLength = 8;
    public const int MaxFailedAttempts = 5;
    public static readonly TimeSpan CodeLifetime = TimeSpan.FromMinutes(15);

    private const string InvalidCodeMessage = "The reset code is invalid or has expired. Please request a new one.";

    private readonly ApplicationDbContext _context;
    private readonly IHashService _hasher;
    private readonly IMessageProducer _producer;
    private readonly ILogger<PasswordResetService> _logger;

    public PasswordResetService(ApplicationDbContext context,
                                IHashService hasher,
                                IMessageProducer producer,
                                ILogger<PasswordResetService> logger)
    {
        _context = context;
        _hasher = hasher;
        _producer = producer;
        _logger = logger;
    }

    public async Task RequestReset(string email)
    {
        var normalized = email?.Trim() ?? string.Empty;
        if (normalized.Length == 0)
            throw new BusinessException("Email address is required.");

        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == normalized && !u.IsDeleted && u.IsActive);
        if (user == null || !string.IsNullOrEmpty(user.SocialProvider))
        {
            _logger.LogInformation("Zahtjev za reset lozinke za nepostojeći ili društveni nalog je zanemaren.");
            return;
        }

        var now = DateTime.UtcNow;
        var code = RandomNumberGenerator.GetInt32(0, (int)Math.Pow(10, CodeLength)).ToString($"D{CodeLength}");

        await using var transaction = await _context.Database.BeginTransactionAsync();

        await _context.PasswordResetTokens
            .Where(t => t.UserId == user.Id && t.UsedAt == null && !t.IsDeleted)
            .ExecuteUpdateAsync(setters => setters.SetProperty(t => t.IsDeleted, true));

        var token = new PasswordResetToken
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            CodeHash = _hasher.Hash(code),
            CreatedAt = now,
            ExpiresAt = now.Add(CodeLifetime),
            FailedAttempts = 0,
            IsDeleted = false
        };

        _context.PasswordResetTokens.Add(token);
        await _context.SaveChangesAsync();
        await transaction.CommitAsync();

        _producer.SendPasswordReset(new PasswordResetRequested
        {
            UserId = user.Id,
            Email = user.Email,
            DisplayName = user.DisplayName,
            Code = code,
            ExpiresAt = token.ExpiresAt
        });
    }

    public async Task ResetPassword(string email, string code, string newPassword)
    {
        var normalizedEmail = email?.Trim() ?? string.Empty;
        var normalizedCode = code?.Trim() ?? string.Empty;

        if (normalizedEmail.Length == 0 || normalizedCode.Length != CodeLength || !normalizedCode.All(char.IsDigit))
            throw new BusinessException(InvalidCodeMessage);

        if (string.IsNullOrWhiteSpace(newPassword) || newPassword.Length < MinimumPasswordLength)
            throw new BusinessException($"The new password must have at least {MinimumPasswordLength} characters.");

        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == normalizedEmail && !u.IsDeleted);
        if (user == null)
            throw new BusinessException(InvalidCodeMessage);

        var now = DateTime.UtcNow;
        var token = await _context.PasswordResetTokens
            .Where(t => t.UserId == user.Id && t.UsedAt == null && !t.IsDeleted && t.ExpiresAt > now)
            .OrderByDescending(t => t.CreatedAt)
            .FirstOrDefaultAsync();

        if (token == null)
            throw new BusinessException(InvalidCodeMessage);

        if (!_hasher.Verify(normalizedCode, token.CodeHash))
        {
            token.FailedAttempts += 1;
            if (token.FailedAttempts >= MaxFailedAttempts)
                token.IsDeleted = true;

            await _context.SaveChangesAsync();
            throw new BusinessException(InvalidCodeMessage);
        }

        await using var transaction = await _context.Database.BeginTransactionAsync();

        token.UsedAt = now;
        user.Password = _hasher.Hash(newPassword);
        user.TokenVersion += 1;

        await _context.SaveChangesAsync();
        await transaction.CommitAsync();

        _producer.Publish(new NotificationEvent
        {
            UserId = user.Id,
            Type = NotificationType.PasswordChanged,
            Title = "Password changed",
            Body = "Your password was reset with a one-time code. If this was not you, contact an administrator immediately.",
            CreatedAt = now
        });
    }
}
