using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Location : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [Required]
    public double Longitude { get; set; }

    [Required]
    public double Latitude { get; set; }

    [Required]
    public string Address { get; set; } = string.Empty;

    [ForeignKey("City")]
    public Guid? CityId { get; set; }

    public virtual City? City { get; set; }

    public bool IsDeleted { get; set; } = false;
}