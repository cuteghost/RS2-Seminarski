namespace Models.DTO.MessengerDTO;

public class MessageGET
{
    public string Content { get; set; }
    public DateTime TimeStamp { get; set; }
    public bool isCurrent { get; set; } = true;
    public Guid SenderId { get; set; }
    public Guid ChatId { get; set; }
    public bool IsRead { get; set; }
}
