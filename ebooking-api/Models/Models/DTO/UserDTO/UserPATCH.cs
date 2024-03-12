namespace Models.DTO.UserDTO;

public class UserPATCH
{
    public string DisplayName { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public DateTime BirthDate { get; set; }
    public string Email { get; set; }
    public string Password { get; set; }
    public byte[]? Image { get; set; }
    public bool IsActive { get; set; }
}
