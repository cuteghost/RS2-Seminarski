using Database.Services.MessagingService;
using Models.Domain;

namespace EBooking.Worker.Handlers;

public class ChatMessageHandler
{
    private readonly IMessageRepository _messages;
    private readonly ILogger<ChatMessageHandler> _logger;

    public ChatMessageHandler(IMessageRepository messages, ILogger<ChatMessageHandler> logger)
    {
        _messages = messages;
        _logger = logger;
    }

    public async Task Handle(WelcomeMessage message)
    {
        if (message.User1Id == Guid.Empty || message.User2Id == Guid.Empty || string.IsNullOrWhiteSpace(message.Message))
        {
            _logger.LogWarning("Chat poruka bez pošiljaoca, primaoca ili sadržaja je odbačena.");
            return;
        }

        var chat = await _messages.GetOrCreateChatAsync(message.User1Id, message.User2Id);
        if (chat == null)
        {
            _logger.LogWarning("Razgovor između {User1} i {User2} nije moguće otvoriti jer jedan od korisnika ne postoji.",
                message.User1Id, message.User2Id);
            return;
        }

        var content = message.Message.Length > MessageRepository.MaxMessageLength
            ? message.Message[..MessageRepository.MaxMessageLength]
            : message.Message;

        await _messages.AddAsync(chat.Id, message.User1Id, content);

        _logger.LogInformation("Sistemska poruka je upisana u razgovor {ChatId}.", chat.Id);
    }
}
