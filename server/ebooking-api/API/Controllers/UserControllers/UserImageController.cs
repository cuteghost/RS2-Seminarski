using API.Exceptions;
using Database.Services.UserImageService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers.UserControllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class UserImageController : Controller
{
    private const string ContentType = "image/jpeg";

    private readonly IUserImageService _imageService;

    public UserImageController(IUserImageService imageService)
    {
        _imageService = imageService;
    }

    [HttpGet]
    [Route("{userId}")]
    [ResponseCache(Duration = 86400, Location = ResponseCacheLocation.Client)]
    public async Task<IActionResult> Get([FromRoute] Guid userId)
    {
        var bytes = await _imageService.GetImage(userId);
        if (bytes == null)
            throw new NotFoundException($"User with identifier {userId} has no profile image.");

        return File(bytes, ContentType);
    }
}
