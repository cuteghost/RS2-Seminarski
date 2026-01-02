public class AccommodationRating
{
    public string CustomerId { get; set; } = string.Empty;
    public string AccommodationId { get; set; } = string.Empty;
    public float Rating { get; set; }
}

public class AccommodationRatingPrediction
{
    public float Score { get; set; }
}
