using System.ComponentModel.DataAnnotations;

namespace Models.DTO.CountryDTO;

public class CountryPATCH
{
    public long Id { get; set; }
    [MaxLength(50)]
    [MinLength(5)]
    public string Name { get; set; } = string.Empty;

}
