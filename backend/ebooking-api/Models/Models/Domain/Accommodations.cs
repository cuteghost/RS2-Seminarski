using Models.Models.Domain;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public partial class Accommodation : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [Required]
    [Column(TypeName = "nvarchar")]
    [MinLength(3)]
    [MaxLength(50)]
    public string Name { get; set; } = string.Empty;

    [Required]
    public bool Status { get; set; }

    [Required]
    public TypesOfAccommodation TypeOfAccommodation { get; set; }

    [Required]
    public double PricePerNight { get; set; }

    [Required]
    public byte[]? ImageThumb { get; set; }

    [Required]
    [Column(TypeName = "nvarchar")]
    [MinLength(50)]
    [MaxLength(1000)]
    public string Description { get; set; } = string.Empty;

    [Column(TypeName = "decimal(3,1)")]
    public float ReviewScore { get; set; }

    [Required]
    [ForeignKey("Owner")]
    public Guid OwnerId { get; set; }

    [Required]
    [ForeignKey("Location")]
    public Guid LocationId { get; set; }

    [ForeignKey("AccommodationDetails")]
    public Guid AccommodationDetailsId { get; set; }
    
    public byte[]? Image { get; set; }
    public string Reviews { get; set; } = string.Empty;

    public bool IsDeleted { get; set; }
    public virtual Partner? Owner { get; set; }
    public virtual Location? Location { get; set; }
    public virtual AccommodationDetails? AccommodationDetails { get; set; }

}
public enum TypesOfAccommodation
{
    House,
    Hotel,
    Resort,
    Apartment,
    Villa,
    Hostel,
    Cottage,
    Penthouse
}

