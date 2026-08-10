using AutoMapper;
using Repository.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.CountryDTO;
using Services.CountryService;
namespace Controllers;

[ApiController]
[Route("/api/[controller]")]
public class CountryController : Controller
{
    ICountryService _countryService;
    public CountryController(ICountryService countryService)
    {
        _countryService=countryService;
    }
    
    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> Add([FromBody] CountryPOST countryDto)
    {
       var result = await _countryService.CreateCountry(countryDto);
       return Ok(result);
    }
    [HttpGet]
    [Route("GetCountries")]
    public async Task<IActionResult> GetCountries()
    {
        return Ok();
    }

    [HttpGet]
    [Route("Get/{id}")]
    public async Task<IActionResult> GetCountry([FromRoute] Guid id)
    {
        return Ok();
    }

    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> DeleteCountry([FromRoute] Guid id)
    {
        return Ok();
    }
    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> UpdateCountry([FromBody] CountryPATCH countryDto)
    {
        return Ok();
    }
}
