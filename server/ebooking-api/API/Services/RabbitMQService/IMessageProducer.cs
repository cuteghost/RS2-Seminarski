using Models.Domain;

namespace Services.RabbitMQService;

public interface IMessageProducer
{
    //public void SendingMessage(string message);
    //public void SendingObject<T>(T obj);
    public void SendMessage(WelcomeMessage message);
}
