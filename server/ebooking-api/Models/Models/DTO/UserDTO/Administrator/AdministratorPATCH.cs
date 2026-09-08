using Models.Domain;

namespace Models.DTO.UserDTO.Administrator;

public class AdministratorPATCH
{
    public string DisplayName { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public DateTime BirthDate { get; set; }
    public Gender Gender { get; set; }
    public byte[]? Image { get; set; }
}
