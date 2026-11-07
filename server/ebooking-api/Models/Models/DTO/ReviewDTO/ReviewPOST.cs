namespace Models.DTO.ReviewDTO;

public class ReviewPOST
{
    public Guid ReservationId { get; set; }
    public Guid AccommodationId { get; set; }
    public int Rating { get; set; }
    public bool Satisfaction { get; set; }
    public bool WouldRecommend { get; set; }
    public string? Comment { get; set; }
    public byte[]? Image { get; set; }
}
