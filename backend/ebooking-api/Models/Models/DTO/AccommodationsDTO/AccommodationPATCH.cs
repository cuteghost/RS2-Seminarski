using Models.Domain;
using Models.DTO.AccommodationDetailsDTO;
using Models.DTO.AccommodationImages;

namespace Models.DTO.AccommodationDTO;

public class AccommodationPATCH
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty; 
    public bool status { get; set; }
    public TypesOfAccommodation TypeOfAccommodation { get; set; }
    public double PricePerNight { get; set; }
    public string Description { get; set; } = string.Empty;
    public AccommodationDetailsPATCH? AccommodationDetails { get; set; }
    public AccommodationImagesPATCH? AccommodationImages { get; set; }
    
}