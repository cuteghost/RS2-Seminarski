using API.Models.DTO.AccommodationDetailsDTO;
using Models.Domain;
using Models.DTO.LocationDTO;

namespace Models.DTO.AccommodationDTO;

public class AccommodationPOST
{
    public int AccommodationId { get; set; }
    public string Name { get; set; } 
    public bool status { get; set; }
    public TypesOfAccommodation TypeOfAccommodation { get; set; }
    public double PricePerNight { get; set; }
    public byte[] ImageThumb { get; set; }
    public string Description { get; set; }
    public float ReviewScore { get; set; }
    public User Owner { get; set; }
    public LocationPOST Location { get; set; }
    public AccommodationDetailsPOST AccommodationDetails { get; set; }
    public byte[] Image { get; set; }
    public string Reviews { get; set; }
    public string StateMachine { get; set; }
    
}