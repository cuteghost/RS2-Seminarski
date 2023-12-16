using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eBooking.Model.Domain;

public class User
{
    [Key]
    [Column(TypeName = "bigint")]
    public long Id { get; set; }
    
    [Required]
    [Column(TypeName = "smallint")]
    public Role Role { get; set; }

    [Required]
    [Column(TypeName = "nvarchar")]
    [MaxLength(15)]
    [MinLength(3)]
    public string DisplayName { get; set; } = string.Empty;

    [Required]
    [Column(TypeName = "nvarchar")]
    [MaxLength(15)]
    [MinLength(3)]
    public string FirstName { get; set; } = string.Empty;
    
    [Required]
    [Column(TypeName = "nvarchar")]
    [MaxLength(30)]
    [MinLength(3)]
    public string LastName { get; set; } = string.Empty;
    
    [Required]
    [Column(TypeName = "date")]
    public DateTime BirthDate { get; set; }
    
    [Column(TypeName = "smallint")]
    public Gender Gender { get; set; }
    
    [Required]
    [Column(TypeName = "nvarchar")]
    [MaxLength(30)]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    [Column(TypeName = "nvarchar")]
    [MaxLength(512)]
    public string Password { get; set; } = string.Empty;

    public byte[]? Image { get; set; }

    public bool isActive { get; set; } = true;

    public virtual Location location { get; set; }
}
public enum Gender
{
    Male = 0,
    Female = 1
}
public enum Role
{
    Administrator,
    Buyer,
    Seller,
}