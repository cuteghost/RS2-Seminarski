using EasyNetQ;
using EBooking.Worker.Handlers;
using Models.Domain;

namespace EBooking.Worker;

public class RabbitMqConsumer : BackgroundService
{
    public const string ChatSubscriptionId = "ebooking-worker-chat";
    public const string NotificationSubscriptionId = "ebooking-worker-notifications";
    public const string PasswordResetSubscriptionId = "ebooking-worker-password-reset";

    private readonly IBus _bus;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<RabbitMqConsumer> _logger;
    private readonly List<IDisposable> _subscriptions = new();

    public RabbitMqConsumer(IBus bus, IServiceScopeFactory scopeFactory, ILogger<RabbitMqConsumer> logger)
    {
        _bus = bus;
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _subscriptions.Add(_bus.PubSub.Subscribe<WelcomeMessage>(
            ChatSubscriptionId, HandleChatMessage, cancellationToken: stoppingToken));

        _subscriptions.Add(_bus.PubSub.Subscribe<NotificationEvent>(
            NotificationSubscriptionId, HandleNotification, cancellationToken: stoppingToken));

        _subscriptions.Add(_bus.PubSub.Subscribe<PasswordResetRequested>(
            PasswordResetSubscriptionId, HandlePasswordReset, cancellationToken: stoppingToken));

        _logger.LogInformation("Worker je pretplaćen na redove {Chat}, {Notifications} i {PasswordReset}.",
            ChatSubscriptionId, NotificationSubscriptionId, PasswordResetSubscriptionId);

        return Task.CompletedTask;
    }

    private async Task HandleChatMessage(WelcomeMessage message)
    {
        using var scope = _scopeFactory.CreateScope();
        var handler = scope.ServiceProvider.GetRequiredService<ChatMessageHandler>();

        try
        {
            await handler.Handle(message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Obrada chat poruke između {User1} i {User2} nije uspjela.", message.User1Id, message.User2Id);
            throw;
        }
    }

    private async Task HandleNotification(NotificationEvent notificationEvent)
    {
        using var scope = _scopeFactory.CreateScope();
        var handler = scope.ServiceProvider.GetRequiredService<NotificationHandler>();

        try
        {
            await handler.Handle(notificationEvent);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Upis notifikacije {Type} za korisnika {UserId} nije uspio.", notificationEvent.Type, notificationEvent.UserId);
            throw;
        }
    }

    private async Task HandlePasswordReset(PasswordResetRequested request)
    {
        using var scope = _scopeFactory.CreateScope();
        var handler = scope.ServiceProvider.GetRequiredService<PasswordResetEmailHandler>();

        try
        {
            await handler.Handle(request);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Slanje koda za reset lozinke korisniku {UserId} nije uspjelo.", request.UserId);
            throw;
        }
    }

    public override void Dispose()
    {
        foreach (var subscription in _subscriptions)
            subscription.Dispose();

        base.Dispose();
    }
}
