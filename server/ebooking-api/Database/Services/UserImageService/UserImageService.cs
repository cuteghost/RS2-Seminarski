using Microsoft.EntityFrameworkCore;

namespace Database.Services.UserImageService;

public class UserImageService : IUserImageService
{
    private readonly ApplicationDbContext _context;

    public UserImageService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<byte[]?> GetImage(Guid userId)
    {
        var image = await _context.Users
            .AsNoTracking()
            .Where(u => u.Id == userId && !u.IsDeleted)
            .Select(u => u.Image)
            .FirstOrDefaultAsync();

        return image != null && image.Length > 0 ? image : null;
    }
}
