namespace Models.DTO.UserDTO;

public class UserPATCH
{
    public string? DisplayName { get; set; } = string.Empty;
    public string? FirstName { get; set; } = string.Empty;
    public string? LastName { get; set; } = string.Empty;
    public DateTime? BirthDate { get; set; }
    public byte[]? Image { get; set; }
}
