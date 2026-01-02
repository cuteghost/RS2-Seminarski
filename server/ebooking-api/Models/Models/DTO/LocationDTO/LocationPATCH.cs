namespace Models.DTO.LocationDTO;

public class LocationPATCH
{
    public Guid Id { get; set; }
    public double Longitude { get; set; }
    public double Latitude { get; set; }
    public string Address { get; set; } = string.Empty;
    public Guid CityId { get; set; }
}
