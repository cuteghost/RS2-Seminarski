namespace Models.DTO.ReviewDTO;

public class AccommodationReviewGET
{
    public Guid Id { get; set; }
    public Guid AccommodationId { get; set; }
    public string CustomerDisplayName { get; set; } = string.Empty;
    public int Rating { get; set; }
    public bool Satisfaction { get; set; }
    public bool WouldRecommend { get; set; }
    public string Comment { get; set; } = string.Empty;
}
