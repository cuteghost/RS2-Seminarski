using Models.Models.Domain;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class City : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }
    [Required]
    public string Name { get; set; } = string.Empty;
    public Guid? CountryId { get; set; }
    [ForeignKey("CountryId")]
    public virtual Country? Country { get; set; }
    public bool IsDeleted { get; set; }

}