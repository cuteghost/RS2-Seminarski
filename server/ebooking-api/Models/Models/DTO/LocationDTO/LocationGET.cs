namespace Models.DTO.LocationDTO;

public class LocationGET
{
    public Guid Id { get; set; }
    public double Longitude { get; set; }
    public double Latitude { get; set; }
    public string Address { get; set; } = string.Empty;
    public Guid CityId { get; set; }
    public string CityName { get; set; } = string.Empty;
    public string CountryName { get; set; } = string.Empty;
    public int AccommodationCount { get; set; }
}
