using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Country
{
    [Key]
    [Column(TypeName = "bigint")]
    public long Id { get; set; }
    [Required]
    public string Name { get; set; } = string.Empty;

}