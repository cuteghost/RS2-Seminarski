using EasyNetQ;
using Microsoft.Extensions.Logging;
using Models.Domain;

namespace Services.RabbitMQService;

public class MessageProducer : IMessageProducer
{
    private readonly IBus _bus;
    private readonly ILogger<MessageProducer> _logger;
    private readonly string _host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
    private readonly string _port = Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672";
    private readonly string _username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "user";
    private readonly string _password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "mypass";
    private readonly string _virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

    public MessageProducer(ILogger<MessageProducer> logger)
    {
        _logger = logger;
        var connectionString = $"host={_host};virtualHost={_virtualhost};username={_username};password={_password};port={_port}";
        _bus = RabbitHutch.CreateBus(connectionString);
    }

    public void SendMessage(WelcomeMessage message)
    {
        _bus.PubSub.Publish(message);
        _logger.LogInformation("Poruka za korisnike {User1} i {User2} je poslana u red.", message.User1Id, message.User2Id);
    }
}
