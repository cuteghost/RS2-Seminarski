using Models.Domain;

namespace Models.DTO.UserDTO.Administrator;

public class AdministratorGET
{
    
    public Guid Id { get; set; }
    public Role Role { get; set; }
    public string DisplayName { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public DateTime BirthDate { get; set; }
    public Gender Gender { get; set; }
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public byte[]? Image { get; set; }
    public bool IsActive { get; set; } = true;
    public virtual Location Location { get; set; }
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
