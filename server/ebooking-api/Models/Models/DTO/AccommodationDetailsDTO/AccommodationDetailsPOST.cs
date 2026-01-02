namespace Models.DTO.AccommodationDetailsDTO;

public class AccommodationDetailsPOST
{
    public int NumberOfBeds { get; set; }
    public List<Guid> AmenityIds { get; set; } = new();
}
