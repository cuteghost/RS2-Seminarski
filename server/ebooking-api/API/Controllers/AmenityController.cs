using Database.Services.AccommodationCatalogService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.DTO.AmenityDTO;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class AmenityController : Controller
{
    private readonly IAccommodationCatalogService _catalog;

    public AmenityController(IAccommodationCatalogService catalog)
    {
        _catalog = catalog;
    }

    [HttpGet]
    [Route("GetAmenities")]
    public async Task<IActionResult> GetAmenities([FromQuery] int page = 1, [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        return Ok(await _catalog.GetAmenities(page, pageSize));
    }

    [HttpGet]
    [Route("Get/{id}")]
    public async Task<IActionResult> GetAmenity([FromRoute] Guid id)
    {
        return Ok(await _catalog.GetAmenity(id));
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> Add([FromBody] AmenityPOST amenityDto)
    {
        return Ok(await _catalog.CreateAmenity(amenityDto));
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> Update([FromBody] AmenityPATCH amenityDto)
    {
        return Ok(await _catalog.UpdateAmenity(amenityDto));
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> Delete([FromRoute] Guid id)
    {
        return Ok(await _catalog.DeleteAmenity(id));
    }
}
