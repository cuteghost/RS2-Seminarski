using System.Net;
using System.Net.Mail;
using Models.Domain;

namespace EBooking.Worker.Handlers;

public class SmtpOptions
{
    public string Host { get; init; } = string.Empty;
    public int Port { get; init; } = 25;
    public string From { get; init; } = string.Empty;
    public string? Username { get; init; }
    public string? Password { get; init; }
    public bool EnableSsl { get; init; }

    public static SmtpOptions FromEnvironment()
    {
        var host = Environment.GetEnvironmentVariable("SMTP_HOST");
        var from = Environment.GetEnvironmentVariable("SMTP_FROM");

        if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(from))
            throw new InvalidOperationException("SMTP is not configured. Set SMTP_HOST and SMTP_FROM environment variables.");

        var port = int.TryParse(Environment.GetEnvironmentVariable("SMTP_PORT"), out var parsed) ? parsed : 25;
        var enableSsl = bool.TryParse(Environment.GetEnvironmentVariable("SMTP_ENABLE_SSL"), out var ssl) && ssl;

        return new SmtpOptions
        {
            Host = host,
            Port = port,
            From = from,
            Username = Environment.GetEnvironmentVariable("SMTP_USERNAME"),
            Password = Environment.GetEnvironmentVariable("SMTP_PASSWORD"),
            EnableSsl = enableSsl
        };
    }
}

public class PasswordResetEmailHandler
{
    private readonly SmtpOptions _options;
    private readonly ILogger<PasswordResetEmailHandler> _logger;

    public PasswordResetEmailHandler(SmtpOptions options, ILogger<PasswordResetEmailHandler> logger)
    {
        _options = options;
        _logger = logger;
    }

    public async Task Handle(PasswordResetRequested request)
    {
        if (request.ExpiresAt <= DateTime.UtcNow)
        {
            _logger.LogWarning("Zahtjev za reset lozinke korisnika {UserId} je istekao prije slanja.", request.UserId);
            return;
        }

        using var message = new MailMessage(_options.From, request.Email)
        {
            Subject = "eBooking password reset code",
            Body = $"Hello {request.DisplayName},\n\n" +
                   $"Your password reset code is: {request.Code}\n\n" +
                   $"The code is valid until {request.ExpiresAt:dd.MM.yyyy. HH:mm} UTC and can be used only once.\n" +
                   "If you did not ask for a password reset, ignore this message.\n\n" +
                   "eBooking"
        };

        using var client = new SmtpClient(_options.Host, _options.Port)
        {
            EnableSsl = _options.EnableSsl
        };

        if (!string.IsNullOrWhiteSpace(_options.Username))
            client.Credentials = new NetworkCredential(_options.Username, _options.Password);

        await client.SendMailAsync(message);

        _logger.LogInformation("Kod za reset lozinke je poslan korisniku {UserId}.", request.UserId);
    }
}
