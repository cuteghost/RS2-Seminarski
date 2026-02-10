using Database.Services.AccommodationCatalogService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.DTO.AccommodationTypeDTO;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class AccommodationTypeController : Controller
{
    private readonly IAccommodationCatalogService _catalog;

    public AccommodationTypeController(IAccommodationCatalogService catalog)
    {
        _catalog = catalog;
    }

    [HttpGet]
    [Route("GetTypes")]
    public async Task<IActionResult> GetTypes([FromQuery] int page = 1, [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        return Ok(await _catalog.GetTypes(page, pageSize));
    }

    [HttpGet]
    [Route("Get/{id}")]
    public async Task<IActionResult> GetType([FromRoute] Guid id)
    {
        return Ok(await _catalog.GetType(id));
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> Add([FromBody] AccommodationTypePOST typeDto)
    {
        return Ok(await _catalog.CreateType(typeDto));
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> Update([FromBody] AccommodationTypePATCH typeDto)
    {
        return Ok(await _catalog.UpdateType(typeDto));
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> Delete([FromRoute] Guid id)
    {
        return Ok(await _catalog.DeleteType(id));
    }
}
