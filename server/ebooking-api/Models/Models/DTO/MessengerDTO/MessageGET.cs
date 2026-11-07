namespace Models.DTO.MessengerDTO;

public class MessageGET
{
    public Guid Id { get; set; }
    public string Content { get; set; } = string.Empty;
    public DateTime TimeStamp { get; set; }
    public bool isCurrent { get; set; } = true;
    public Guid SenderId { get; set; }
    public Guid ChatId { get; set; }
    public bool IsRead { get; set; }
}
