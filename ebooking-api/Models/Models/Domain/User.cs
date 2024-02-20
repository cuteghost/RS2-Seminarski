using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class User
{
    [Required]
    [Key]
    public int Id { get; set; }

    [Required]
    public string Email { get; set; }

    [Required]
    public string Password { get; set; } = string.Empty;

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

    public byte[]? Image { get; set; }

    public bool IsActive { get; set; } = true;
}
public enum Gender
{
    Male = 0,
    Female = 1
}
