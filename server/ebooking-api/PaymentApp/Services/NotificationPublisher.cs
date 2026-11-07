using EasyNetQ;
using Models.Domain;

namespace PaymentApp.Services;

public interface INotificationPublisher
{
    void Publish(NotificationEvent notificationEvent);
}

public class NotificationPublisher : INotificationPublisher, IDisposable
{
    private readonly IBus _bus;
    private readonly ILogger<NotificationPublisher> _logger;

    public NotificationPublisher(string connectionString, ILogger<NotificationPublisher> logger)
    {
        _bus = RabbitHutch.CreateBus(connectionString);
        _logger = logger;
    }

    public void Publish(NotificationEvent notificationEvent)
    {
        try
        {
            _bus.PubSub.Publish(notificationEvent);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Notifikacija {Type} za korisnika {UserId} nije poslana u red.",
                notificationEvent.Type, notificationEvent.UserId);
        }
    }

    public void Dispose()
    {
        _bus.Dispose();
    }
}
