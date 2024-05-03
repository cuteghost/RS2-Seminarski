using Models.Domain;

namespace Models.DTO.UserDTO;

public class UserGET
{
    public Guid UserId { get; set; }
    public string UserDisplayName { get; set; } = string.Empty;
    public string UserFirstName { get; set; } = string.Empty;
    public string UserLastName { get; set; } = string.Empty;
    public DateTime UserBirthDate { get; set; }
    public Gender UserGender { get; set; }
    public string UserEmail { get; set; } = string.Empty;
    public string UserSocialLink { get; set; } = string.Empty;
    public bool UserisActive { get; set; } = true;
    public byte[]? UserImage { get; set; }
}
public enum Gender
{
    Male = 0,
    Female = 1
}
public enum Role
{
    Administrator,
    Customer,
    Partner,
}
