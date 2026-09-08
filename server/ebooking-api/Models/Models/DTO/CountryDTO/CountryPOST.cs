using System.ComponentModel.DataAnnotations;

namespace Models.DTO.CountryDTO;

public class CountryPOST
{
    [MaxLength(50)]
    [MinLength(3)]
    public string Name { get; set; } = string.Empty;
}
