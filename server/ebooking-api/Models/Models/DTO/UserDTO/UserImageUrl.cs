namespace Models.DTO.UserDTO;

public static class UserImageUrl
{
    public static string For(Guid userId) => $"/api/UserImage/{userId}";
}
