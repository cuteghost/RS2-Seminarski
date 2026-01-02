using Models.DTO.LocationDTO;
using Models.DTO.AccommodationDetailsDTO;

namespace Models.DTO.AccommodationDTO;

public class AccommodationGET
{
    public Guid Id { get; set; }
    public string? Name { get; set; }
    public bool? Status { get; set; }
    public Guid AccommodationTypeId { get; set; }
    public string AccommodationTypeName { get; set; } = string.Empty;
    public double PricePerNight { get; set; }
    public string Description { get; set; } = string.Empty;
    public float ReviewScore { get; set; }
    public Guid OwnerId { get; set; }
    public LocationGET? Location { get; set; }
    public int ImageCount { get; set; }
    public List<string> ImageUrls { get; set; } = new();
    public AccommodationDetailsGET? AccommodationDetails { get; set; }
}