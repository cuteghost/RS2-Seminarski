using System.ComponentModel.DataAnnotations;

namespace Models.DTO.AccommodationTypeDTO;

public class AccommodationTypePATCH
{
    [Required]
    public Guid Id { get; set; }

    [Required]
    [MaxLength(50)]
    [MinLength(2)]
    public string Name { get; set; } = string.Empty;

    public int SortOrder { get; set; }
}
