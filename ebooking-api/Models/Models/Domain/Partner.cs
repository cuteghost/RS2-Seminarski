using Models.Models.Domain;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Partner : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [Required]
    public User User { get; set; }

    [Required]
    public DateTime DateJoined { get; set; }
    public bool IsDeleted { get; set; }

}
