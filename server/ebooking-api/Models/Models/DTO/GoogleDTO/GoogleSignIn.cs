using System.ComponentModel.DataAnnotations;

namespace Models.DTO.GoogleDTO;

public class GoogleSignInVM
{
    [Required]
    public string IdToken { get; set; }
    [Required]
    public string AccessToken { get; set; }
}
