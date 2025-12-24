public class AccommodationRating
{
    public float CustomerId { get; set; }
    public float AccommodationId { get; set; }
    public float Rating { get; set; }
    public float PricePerNight { get; set; }
    public float ReviewScore { get; set; }
}

public class AccommodationRatingPrediction
{
    public float Score { get; set; }
}
