namespace Models.DTO.LocationDTO;

public class LocationGet
{
    public Guid Id { get; set; }
    public string Address { get; set; } = string.Empty;
    public string CityName { get; set; } = string.Empty;
    public string CountryName { get; set; } = string.Empty;

}
