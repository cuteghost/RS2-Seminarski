using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Amenity : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [Required]
    [MaxLength(50)]
    public string Code { get; set; } = string.Empty;

    [Required]
    [MaxLength(80)]
    public string Name { get; set; } = string.Empty;

    public int SortOrder { get; set; }

    public bool IsDeleted { get; set; } = false;

    public virtual ICollection<AccommodationDetailsAmenity> AccommodationDetailsAmenities { get; set; } = new List<AccommodationDetailsAmenity>();
}
