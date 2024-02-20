using System.ComponentModel.DataAnnotations;

namespace Models.Domain;

public class Customer
{
    [Required]
    [Key]
    public long Id { get; set; }
    
    [Required]
    public DateTime Joined { get; set; }

    [Required]
    public User User { get; set; }

}
