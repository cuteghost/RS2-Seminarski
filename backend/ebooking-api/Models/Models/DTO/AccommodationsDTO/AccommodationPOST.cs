using Models.DTO.AccommodationDetailsDTO;
using Models.Domain;
using Models.DTO.LocationDTO;
using Models.DTO.AccommodationImages;

namespace Models.DTO.AccommodationDTO;

public class AccommodationPOST
{
    public string Name { get; set; } = string.Empty;
    public TypesOfAccommodation TypeOfAccommodation { get; set; }
    public double PricePerNight { get; set; }
    public byte[]? ImageThumb { get; set; }
    public string Description { get; set; } = string.Empty;
    public AccommodationImagesPOST? AccommodationImages { get; set; }
    public LocationPOST? Location { get; set; }
    public AccommodationDetailsPOST? AccommodationDetails { get; set; }
    
}