using Models.Models.Domain;
using System.ComponentModel.DataAnnotations;

namespace Models.Domain;

public class Partner : ISoftDeleted
{
    [Required]
    [Key]
    public long Id { get; set; }

    [Required]
    public User User { get; set; }

    [Required]
    public DateTime DateJoined { get; set; }
    public bool IsDeleted { get; set; }

}
