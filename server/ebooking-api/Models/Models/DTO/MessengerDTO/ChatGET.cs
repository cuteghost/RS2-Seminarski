namespace Models.DTO.MessengerDTO;

public class ChatGET
{
    public Guid Id { get; set; }
    public Guid User1Id { get; set; }
    public Guid User2Id { get; set; }
    public string User1 { get; set; } = string.Empty;
    public string User2 { get; set; } = string.Empty;
    public MessageGET? LastMessage { get; set; }
    public int UnreadCount { get; set; }
}
