using Models.Domain;

namespace Services.RabbitMQService;

public interface IMessageProducer
{
    void SendMessage(WelcomeMessage message);

    void Publish(NotificationEvent notificationEvent);

    void SendPasswordReset(PasswordResetRequested request);
}
