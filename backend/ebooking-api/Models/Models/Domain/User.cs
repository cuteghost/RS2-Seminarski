using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class User : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [Required]
    public string Email { get; set; }

    [Required]
    public string Password { get; set; } = string.Empty;

    [Required]
    [Column(TypeName = "nvarchar")]
    [MaxLength(50)]
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

    public string SocialLink { get; set; } = string.Empty;

    [Required]
    public DateTime Joined { get; set; }

    public byte[]? Image { get; set; }

    public bool IsActive { get; set; } = true;

    public bool IsDeleted { get; set; } = false;

    public Role Role { get; set; } = 0;
}
public enum Gender
{
    Male = 0,
    Female = 1
}
public enum Role
{
    AdministratorRole=1337,
    CustomerRole = 0,
    PartnerRole = 1,

}
