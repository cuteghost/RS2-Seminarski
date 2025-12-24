namespace Models.Domain;

public class WelcomeMessage
{
    public string Message { get; set; }
    public DateTime TimeStamp { get; set; }
    public Guid User1Id { get; set; }
    public Guid User2Id { get; set; }
}
