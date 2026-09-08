namespace Models.DTO.UserDTO;

public class ManagedUserPATCH : UserPATCH
{
    public string? SocialLink { get; set; }
    public bool? IsActive { get; set; }
}
