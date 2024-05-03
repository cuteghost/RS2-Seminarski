using Models.Models.Domain;
using System.ComponentModel.DataAnnotations;

namespace Models.Domain;

public class Customer : ISoftDeleted
{
    [Required]
    [Key]
    public Guid Id { get; set; }

    [Required]
    public User User { get; set; }

    public bool IsDeleted { get; set; } = false;
}
