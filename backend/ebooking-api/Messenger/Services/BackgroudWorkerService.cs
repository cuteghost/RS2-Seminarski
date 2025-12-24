using EasyNetQ;
using Models.Domain;

namespace Messenger;

public class ConsumeRabbitMQHostedService : BackgroundService
{
    private readonly ILogger<ConsumeRabbitMQHostedService> _logger;
    private IBus _bus;
    private readonly IServiceProvider _serviceProvider;
    private readonly string _host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
    private readonly string _username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "user";
    private readonly string _password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "mypass";
    private readonly string _virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";
    private readonly string _port = Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672";
    
    public ConsumeRabbitMQHostedService(ILogger<ConsumeRabbitMQHostedService> logger, IServiceProvider serviceProvider)
    {
        _logger = logger;
        InitRabbitMQ();
        _serviceProvider = serviceProvider;
    }

    private void InitRabbitMQ()
    {
        var connectionString = $"host={_host};virtualHost={_virtualhost};username={_username};password={_password};port={_port}";
        _bus = RabbitHutch.CreateBus(connectionString);
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _bus.PubSub.Subscribe<WelcomeMessage>("subscriptionId", HandleMessage, cancellationToken: stoppingToken);
        return Task.CompletedTask;
    }

    private async Task HandleMessage(WelcomeMessage welcomeMessage)
    {
        using (var scope = _serviceProvider.CreateScope())
        {
            var notifier = scope.ServiceProvider.GetRequiredService<INotifierService>();
            _logger.LogInformation($"consumer received: {System.Text.Json.JsonSerializer.Serialize(welcomeMessage)}");
            await notifier.Notify(welcomeMessage);
        }
    }

    public override void Dispose()
    {
        _bus.Dispose();
        base.Dispose();
    }
}