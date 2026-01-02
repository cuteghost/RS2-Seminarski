using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class AccommodationDetails : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    public int NumberOfBeds { get; set; }

    public bool IsDeleted { get; set; }

    public virtual ICollection<AccommodationDetailsAmenity> AccommodationDetailsAmenities { get; set; } = new List<AccommodationDetailsAmenity>();
}
