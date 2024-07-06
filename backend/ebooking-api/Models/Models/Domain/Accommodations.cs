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

    public bool Status { get; set; }

    [Required]
    public TypesOfAccommodation TypeOfAccommodation { get; set; }

    [Required]
    public double PricePerNight { get; set; }

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
    
    public AccommodationImages? AccommodationImages { get; set; }

    public Location? Location { get; set; }

    public AccommodationDetails? AccommodationDetails { get; set; }

    public bool IsDeleted { get; set; }
    public virtual Partner? Owner { get; set; }
}
public enum TypesOfAccommodation
{
    House = 1,
    Hotel,
    Resort,
    Apartment,
    Villa,
    Hostel,
    Cottage,
    Penthouse
}

