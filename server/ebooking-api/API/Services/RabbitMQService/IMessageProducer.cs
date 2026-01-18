using Models.Domain;

namespace Services.RabbitMQService;

public interface IMessageProducer
{
    public void SendMessage(WelcomeMessage message);
}
