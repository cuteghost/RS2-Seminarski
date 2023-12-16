using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Runtime.CompilerServices;

namespace eBooking.Model.Domain;

public partial class Accommodations
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid AccommodationId { get; set; } = new Guid();
    
    [Required]
    [Column(TypeName = "nvarchar")]
    [MinLength(3)]
    [MaxLength(50)]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    public bool status { get; set; }
    
    [Required]
    public TypesOfAccommodations TypeOfAccommodation { get; set; }
    
    [Required]
    public double PricePerNight { get; set; }
    
    [Required]
    public byte[] ImageThumb { get; set; }
    
    [Required]
    [Column(TypeName = "nvarchar")]
    [MinLength(50)]
    [MaxLength(1000)]
    public string Description { get; set; }
    
    [Column(TypeName = "decimal(3,1)")]
    public float ReviewScore { get; set; }
    
    [Required]
    public User Owner { get; set; }

    [Required]
    public Location Location { get; set; }
    
    public string AccommodationDetails { get; set; }
    public byte[] Image { get; set; }
    public string Reviews { get; set; }

    public string StateMachine { get; set; }
}
public enum TypesOfAccommodations
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

