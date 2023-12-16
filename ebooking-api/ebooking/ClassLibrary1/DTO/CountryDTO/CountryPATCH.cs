using System.ComponentModel.DataAnnotations;

namespace eBooking.Model.DTO;

public class CountryPATCH
{
    public long Id { get; set; }
    [MaxLength(50)]
    [MinLength(5)]
    public string Name { get; set; } = string.Empty;

}
