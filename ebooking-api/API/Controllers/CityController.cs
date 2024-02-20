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
    public IActionResult Add([FromBody]CityPOST cityDto )
    {   
        var city = _mapper.Map<City>(cityDto);
        _cityRepo.Add(city);

        return Content("Ok");
    }
    [HttpGet]
    [Route("GetCities")]
    public IActionResult GetCities()
    {
        var rawCities = _cityRepo.GetAll(c => c.Country);
        var cities = _mapper.Map<List<CityGET>>(rawCities);
        return Json(cities);
    }
}
