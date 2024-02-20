using System.ComponentModel.DataAnnotations;

namespace Models.DTO.CityDTO;

public class CityPATCH
{
    public long Id { get; set; }
    [MaxLength(50)]
    [MinLength(5)]
    public string Name { get; set; } = string.Empty;
    public long CountryId { get; set; }

}
