using EasyNetQ;
using Microsoft.Extensions.Logging;
using Models.Domain;

namespace Services.RabbitMQService;

public class MessageProducer : IMessageProducer, IDisposable
{
    private readonly IBus _bus;
    private readonly ILogger<MessageProducer> _logger;

    public MessageProducer(string connectionString, ILogger<MessageProducer> logger)
    {
        _logger = logger;
        _bus = RabbitHutch.CreateBus(connectionString);
    }

    public void SendMessage(WelcomeMessage message)
    {
        try
        {
            _bus.PubSub.Publish(message);
            _logger.LogInformation("Poruka za korisnike {User1} i {User2} je poslana u red.", message.User1Id, message.User2Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Poruka za korisnike {User1} i {User2} nije poslana u red.", message.User1Id, message.User2Id);
        }
    }

    public void Publish(NotificationEvent notificationEvent)
    {
        try
        {
            _bus.PubSub.Publish(notificationEvent);
            _logger.LogInformation("Notifikacija {Type} za korisnika {UserId} je poslana u red.", notificationEvent.Type, notificationEvent.UserId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Notifikacija {Type} za korisnika {UserId} nije poslana u red.", notificationEvent.Type, notificationEvent.UserId);
        }
    }

    public void SendPasswordReset(PasswordResetRequested request)
    {
        try
        {
            _bus.PubSub.Publish(request);
            _logger.LogInformation("Zahtjev za reset lozinke korisnika {UserId} je poslan u red.", request.UserId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Zahtjev za reset lozinke korisnika {UserId} nije poslan u red.", request.UserId);
        }
    }

    public void Dispose()
    {
        _bus.Dispose();
    }
}
