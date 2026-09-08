namespace Models.DTO.UserDTO;

public class UserListItemGET
{
    public Guid UserId { get; set; }
    public string UserDisplayName { get; set; } = string.Empty;
    public string UserFirstName { get; set; } = string.Empty;
    public string UserLastName { get; set; } = string.Empty;
    public DateTime UserBirthDate { get; set; }
    public Gender UserGender { get; set; }
    public string UserEmail { get; set; } = string.Empty;
    public string UserSocialLink { get; set; } = string.Empty;
    public string? UserSocialProvider { get; set; }
    public bool UserIsSocialAccount => !string.IsNullOrEmpty(UserSocialProvider);
    public bool UserIsActive { get; set; } = true;
    public Role Role { get; set; }
}
