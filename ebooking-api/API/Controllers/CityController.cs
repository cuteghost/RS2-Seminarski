using AutoMapper;
using eBooking.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.CityDTO;

namespace Controllers;

[ApiController]
[Route("/api/[controller]")]
public class CityController : Controller
{
    private readonly IMapper _mapper;
    private readonly IGenericRepository<City> _cityRepo;
    public CityController(IGenericRepository<City> cityRepo, IMapper mapper)
    {
        _cityRepo = cityRepo;
        _mapper = mapper;
    }
    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> Add([FromBody]CityPOST cityDto )
    {   
        var city = _mapper.Map<City>(cityDto);
        await _cityRepo.Add(city);

        return Content("Ok");
    }
    [HttpGet]
    [Route("GetCities")]
    public async Task<IActionResult> GetCities()
    {
        var rawCities = await _cityRepo.GetAll(false, c => c.Country);
        var cities = _mapper.Map<List<CityGET>>(rawCities);
        return Json(cities);
    }
}
