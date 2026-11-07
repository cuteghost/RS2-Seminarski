namespace Models.DTO.MessengerDTO;

public class PagedMessagesGET
{
    public List<MessageGET> Items { get; set; } = new();
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalCount { get; set; }
    public bool HasMore { get; set; }
}
