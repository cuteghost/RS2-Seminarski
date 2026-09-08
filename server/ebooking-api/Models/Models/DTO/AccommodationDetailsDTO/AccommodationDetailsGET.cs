using Models.DTO.AmenityDTO;

namespace Models.DTO.AccommodationDetailsDTO;

public class AccommodationDetailsGET
{
    public Guid Id { get; set; }
    public int NumberOfBeds { get; set; }
    public List<AmenityGET> Amenities { get; set; } = new();
}
