﻿namespace Models.DTO.UserDTO;

public class UserPATCH
{
    public string DisplayName { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public DateTime BirthDate { get; set; }
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public byte[]? Image { get; set; }
    public bool IsActive { get; set; }
}
