namespace Models.DTO.AccommodationDTO;

public class RecommendedAccommodationGET : AccommodationGET
{
    public string Reason { get; set; } = string.Empty;
    public List<string> Reasons { get; set; } = new();
    public double RecommendationScore { get; set; }
}
