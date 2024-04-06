using Models.Domain;

namespace Models.DTO.AccommodationDTO;

public class AccommodationGET
{
    public Guid Id { get; set; }
    public string? Name { get; set; } 
    public bool status { get; set; }
    public TypesOfAccommodation TypeOfAccommodation { get; set; }
    public double PricePerNight { get; set; }
    public byte[]? ImageThumb { get; set; }  
    public string Description { get; set; } = string.Empty;
    public float ReviewScore { get; set; }
    public User? Owner { get; set; }
    public Location? Location { get; set; }
    public AccommodationDetails? AccommodationDetails { get; set; }
    public byte[]? Image { get; set; }
    public string Reviews { get; set; } = string.Empty;
    public string StateMachine { get; set; } = string.Empty;
    
}