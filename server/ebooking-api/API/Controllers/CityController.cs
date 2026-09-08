using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.DTO.CityDTO;
using Services.CityService;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class CityController : Controller
{
    private readonly ICityService _cityService;

    public CityController(ICityService cityService)
    {
        _cityService = cityService;
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> Add([FromBody] CityPOST cityDto)
    {
        var result = await _cityService.CreateCity(cityDto);
        return Ok(result);
    }

    [HttpGet]
    [Route("GetCities")]
    public async Task<IActionResult> GetCities([FromQuery] int page = 1, [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        var result = await _cityService.GetCities(page, pageSize);
        return Ok(result);
    }

    [HttpGet]
    [Route("GetCityByCountry/{countryId}")]
    public async Task<IActionResult> GetCityByCountry([FromRoute] Guid countryId,
                                                      [FromQuery] int page = 1,
                                                      [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        var result = await _cityService.GetCitiesByCountry(countryId, page, pageSize);
        return Ok(result);
    }

    [HttpGet]
    [Route("Get/{id}")]
    public async Task<IActionResult> GetCity([FromRoute] Guid id)
    {
        var result = await _cityService.GetCity(id);
        return Ok(result);
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> UpdateCity([FromBody] CityPATCH cityDto)
    {
        var result = await _cityService.UpdateCity(cityDto);
        return Ok(result);
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> DeleteCity([FromRoute] Guid id)
    {
        var result = await _cityService.DeleteCity(id);
        return Ok(result);
    }
}
