using System.ComponentModel.DataAnnotations;

namespace Models.DTO.LocationDTO;

public class LocationPOST
{
    public double Longitude { get; set; }
    public double Latitude { get; set; }
    public string Address { get; set; } = string.Empty;
    public Guid CityId { get; set; }
}
