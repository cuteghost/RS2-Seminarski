using System.ComponentModel.DataAnnotations;

namespace Models.DTO.LocationDTO;

public class LocationPOST
{
    [MaxLength(50)]
    [MinLength(5)]
    public string Address { get; set; } = string.Empty;
    public long CityId { get; set; }
}
