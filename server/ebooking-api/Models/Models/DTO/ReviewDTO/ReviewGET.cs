namespace Models.DTO.ReviewDTO;

public class ReviewGET
{
    public Guid Id { get; set; }
    public Guid AccommodationId { get; set; }
    public Guid CustomerId { get; set; }
    public int Rating { get; set; }
    public bool Satisfaction { get; set; }
    public bool WouldRecommend { get; set; }
    public string Comment { get; set; } = string.Empty;
}
