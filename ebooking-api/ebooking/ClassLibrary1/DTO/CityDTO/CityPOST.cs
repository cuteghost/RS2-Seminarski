using System.ComponentModel.DataAnnotations;

namespace eBooking.Model.DTO;
public class CityPOST
{
    [MaxLength(50)]
    [MinLength(5)]
    public string Name { get; set; } = string.Empty;
    public long CountryId { get; set; }
}
