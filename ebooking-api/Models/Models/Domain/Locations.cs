using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Location
{
    [Key]
    [Column(TypeName = "bigint")]
    public long Id { get; set; }
    [Required]
    public double Longitude { get; set; }
    [Required]
    public double Latitude { get; set; }
    [Required]
    public string Address { get; set; } = string.Empty;
    [Required]
    public int ZipCode { get; set; }
    public long? CityId { get; set; }
    [ForeignKey("CityId")]
    public virtual City? City { get; set; }
}