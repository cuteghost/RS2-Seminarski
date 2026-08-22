using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.DTO.CountryDTO;
using Services.CountryService;
namespace Controllers;

[ApiController]
[Route("/api/[controller]")]
public class CountryController : Controller
{
    private readonly ICountryService _countryService;
    public CountryController(ICountryService countryService)
    {
        _countryService = countryService;
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> Add([FromBody] CountryPOST countryDto)
    {
        var result = await _countryService.CreateCountry(countryDto);
        return Ok(result);
    }

    [Authorize]
    [HttpGet]
    [Route("GetCountries")]
    public async Task<IActionResult> GetCountries([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var result = await _countryService.GetCountries(page, pageSize);
        return Ok(result);
    }

    [Authorize]
    [HttpGet]
    [Route("Get/{id}")]
    public async Task<IActionResult> GetCountry([FromRoute] Guid id)
    {
        var result = await _countryService.GetCountry(id);
        return Ok(result);
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> DeleteCountry([FromRoute] Guid id)
    {
        var result = await _countryService.DeleteCountry(id);
        return Ok(result);
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> UpdateCountry([FromBody] CountryPATCH countryDto)
    {
        var result = await _countryService.UpdateCountry(countryDto);
        return Ok(result);
    }
}
