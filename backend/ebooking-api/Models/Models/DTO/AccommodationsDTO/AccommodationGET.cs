using Models.Domain;
using Models.DTO.LocationDTO;
using Models.DTO.AccommodationDetailsDTO;
using Models.DTO.AccommodationImages;

namespace Models.DTO.AccommodationDTO;

public class AccommodationGET
{
    public Guid Id { get; set; }
    public string? Name { get; set; } 
    public bool? Status { get; set; }
    public TypesOfAccommodation TypeOfAccommodation { get; set; }
    public double PricePerNight { get; set; }
    public string Description { get; set; } = string.Empty;
    public float ReviewScore { get; set; }
    public Guid OwnerId { get; set; }
    public LocationGET? Location { get; set; }
    public AccommodationImagesGET? AccommodationImages { get; set; }
    public AccommodationDetailsGET? AccommodationDetails { get; set; }
    public string Reviews { get; set; } = string.Empty;    
}