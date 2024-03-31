using System.ComponentModel.DataAnnotations;

namespace Models.DTO.LocationDTO;

public class LocationPatch
{
    public Guid Id { get; set; }
    [MaxLength(50)]
    [MinLength(5)]
    public string Address { get; set; } = string.Empty;
    public Guid CityId { get; set; }

}
