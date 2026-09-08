namespace Models.DTO.AccommodationTypeDTO;

public class AccommodationTypeGET
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int SortOrder { get; set; }
}
