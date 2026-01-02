namespace Models.DTO.AccommodationDetailsDTO;

public class AccommodationDetailsPATCH
{
    public int NumberOfBeds { get; set; }
    public List<Guid> AmenityIds { get; set; } = new();
}
