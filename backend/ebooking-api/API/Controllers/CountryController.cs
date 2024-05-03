using AutoMapper;
using Repository.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.CountryDTO;

namespace Controllers;

[ApiController]
[Route("/api/[controller]")]
public class CountryController : Controller
{
    private readonly IGenericRepository<Country> _countryRepo;
    private readonly IMapper _mapper;
    public CountryController(IGenericRepository<Country> countryRepo, IMapper mapper)
    {
        _countryRepo = countryRepo;
        _mapper = mapper;
    }
    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> Add([FromBody]CountryPOST countryDto)
    {
        var country = _mapper.Map<Country>(countryDto);
        await _countryRepo.Add(country);

        return Content("Ok");
    }
    [HttpGet]
    [Route("GetCountries")]
    public async Task<IActionResult> GetCountries()
    {
        return Json(await _countryRepo.GetAll());
    }

    [HttpGet]
    [Route("Get/{id}")]
    public async Task<IActionResult> GetCountry([FromRoute] Guid id)
    {
        return Json(await _countryRepo.Get(c=> c.Id == id, false));
    }

    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> DeleteCountry([FromRoute] Guid  id)
    {
        if (await _countryRepo.Delete(c => c.Id == id))
            return Content("OK");
        else
            return Content("Not Found");
    }
    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> UpdateCountry([FromBody]CountryPATCH countryDto) 
    {

        var country = _mapper.Map<Country>(countryDto);
        if (await _countryRepo.Update(c => c.Id == country.Id, country))
            return Content("OK");
        else
            return Content("Not Found");
    }
}
