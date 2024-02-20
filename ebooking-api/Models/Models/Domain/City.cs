using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class City
{
    [Key]
    [Column(TypeName = "bigint")]
    public long Id { get; set; }
    [Required]
    public string Name { get; set; } = string.Empty;
    public long? CountryId { get; set; }
    [ForeignKey("CountryId")]
    public virtual Country? Country { get; set; }

}