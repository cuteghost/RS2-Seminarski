using Models.Domain;

namespace Models.DTO.UserDTO.Administrator;

public class AdministratorGET
{
    
    public Guid userId { get; set; }
    public Role Role { get; set; }
    public string userDisplayName { get; set; } = string.Empty;
    public string userFirstName { get; set; } = string.Empty;
    public string userLastName { get; set; } = string.Empty;
    public DateTime userBirthDate { get; set; }
    public Gender userGender { get; set; }
    public string userEmail { get; set; } = string.Empty;
    public string userPassword { get; set; } = string.Empty;
    public byte[]? userImage { get; set; }
    public string userSocialLink { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
}


