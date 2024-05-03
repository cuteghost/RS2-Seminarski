using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Partner : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [ForeignKey("User")]
    public Guid? UserId { get; set; }
    
    [Required]
    [ForeignKey("Country")]
    public Guid? CountryId { get; set; }

    [Required]
    public bool IsDeleted { get; set; }

    [Required]
    public long TaxId { get; set; }

    [Required]
    public string TaxName { get; set; } = string.Empty;

    [Required]
    public long PhoneNumber { get; set; }

    public virtual Country? Country { get; set; }
    public virtual User? User { get; set; }
    public virtual Location? Location { get; set; }
}
