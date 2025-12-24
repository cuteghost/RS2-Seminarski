namespace Models.DTO.LocationDTO;

public class LocationGET
{
    public double Longitude { get; set; }
    public double Latitude { get; set; }
    public string Address { get; set; } = string.Empty;
    public string CityName { get; set; } = string.Empty;
    public string CountryName { get; set; } = string.Empty;

}
