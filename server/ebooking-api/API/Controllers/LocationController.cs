using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.DTO.LocationDTO;
using Services.LocationCatalogService;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class LocationController : Controller
{
    private readonly ILocationCatalogService _locationService;

    public LocationController(ILocationCatalogService locationService)
    {
        _locationService = locationService;
    }

    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> Add([FromBody] LocationPOST locationDto)
    {
        var result = await _locationService.CreateLocation(locationDto);
        return Ok(result);
    }

    [HttpGet]
    [Route("GetLocations")]
    public async Task<IActionResult> GetLocations([FromQuery] int page = 1, [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        var result = await _locationService.GetLocations(page, pageSize);
        return Ok(result);
    }

    [HttpGet]
    [Route("Get/{id}")]
    public async Task<IActionResult> GetLocation([FromRoute] Guid id)
    {
        var result = await _locationService.GetLocation(id);
        return Ok(result);
    }

    /// <summary>
    /// Provjera ko smije mijenjati lokaciju je u servisu: administrator uvijek, partner samo
    /// ako na toj lokaciji ima svoj smještaj. Zato ovdje nema <c>[Authorize(Roles = ...)]</c>.
    /// </summary>
    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> UpdateLocation([FromBody] LocationPATCH locationDto)
    {
        var result = await _locationService.UpdateLocation(locationDto);
        return Ok(result);
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> DeleteLocation([FromRoute] Guid id)
    {
        var result = await _locationService.DeleteLocation(id);
        return Ok(result);
    }
}
