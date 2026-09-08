namespace Database.Services.UserImageService;

public interface IUserImageService
{
    Task<byte[]?> GetImage(Guid userId);
}
