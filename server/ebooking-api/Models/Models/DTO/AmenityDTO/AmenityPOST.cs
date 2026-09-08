using System.ComponentModel.DataAnnotations;

namespace Models.DTO.AmenityDTO;

public class AmenityPOST
{
    [Required]
    [MaxLength(50)]
    [MinLength(2)]
    public string Code { get; set; } = string.Empty;

    [Required]
    [MaxLength(80)]
    [MinLength(2)]
    public string Name { get; set; } = string.Empty;

    public int SortOrder { get; set; }
}
