using API.Exceptions;
using Database.Services.AccommodationImageService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTO.AccommodationDTO;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class AccommodationImageController : Controller
{
    private const string ContentType = "image/jpeg";

    private readonly IAccommodationImageService _imageService;

    public AccommodationImageController(IAccommodationImageService imageService)
    {
        _imageService = imageService;
    }

    [HttpGet]
    [Route("{accommodationId}/{index}")]
    [ResponseCache(Duration = 86400, Location = ResponseCacheLocation.Client)]
    public async Task<IActionResult> Get([FromRoute] Guid accommodationId, [FromRoute] int index)
    {
        if (index < 1 || index > AccommodationImageUrl.MaxImages)
            throw new BusinessException($"Image number must be between 1 and {AccommodationImageUrl.MaxImages}.");

        var bytes = await _imageService.GetImage(accommodationId, index);
        if (bytes == null)
            throw new NotFoundException($"Image number {index} for accommodation {accommodationId} does not exist.");

        return File(bytes, ContentType);
    }
}
