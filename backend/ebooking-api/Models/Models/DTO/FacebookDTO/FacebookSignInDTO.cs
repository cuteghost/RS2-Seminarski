using System.ComponentModel.DataAnnotations;

namespace Models.DTO.FacebookDTO;

public class FacebookSignInDTO
{
    [Required]
    public string AccessToken { get; set; }
}
