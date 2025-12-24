using System.ComponentModel.DataAnnotations;

namespace Models.DTO.AuthDTO;

public class LoginDTO
{
    [Required]
    [DataType(DataType.EmailAddress)]
    public string Email { get; set; }
    [DataType(DataType.Password)]
    public string Password { get; set; }
}
