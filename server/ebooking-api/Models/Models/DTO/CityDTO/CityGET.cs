namespace Models.DTO.CityDTO;

public class CityGET
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public Guid CountryId { get; set; }
    public string CountryName { get; set; } = string.Empty;
}
