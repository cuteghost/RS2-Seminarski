using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class AccommodationDetailsAmenity
{
    [Column(TypeName = "uniqueidentifier")]
    public Guid AccommodationDetailsId { get; set; }

    [Column(TypeName = "uniqueidentifier")]
    public Guid AmenityId { get; set; }

    public virtual AccommodationDetails? AccommodationDetails { get; set; }

    public virtual Amenity? Amenity { get; set; }
}
