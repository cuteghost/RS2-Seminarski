using AutoMapper;
using Repository.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.LocationDTO;
using System.Security.AccessControl;

namespace Controllers;

[ApiController]
[Route("/api/[controller]")]
public class LocationController : Controller
{
    private readonly IGenericRepository<Location> _locationRepo;
    private readonly IMapper _mapper;

    public LocationController(IGenericRepository<Location> locationRepo, IMapper mapper)
    {
        _locationRepo = locationRepo;
        _mapper = mapper;
    }
    [HttpPost]
    [Route("Add")]
    public IActionResult Add([FromBody]LocationPOST locationDto)
    {
        var location = _mapper.Map<Location>(locationDto);
        _locationRepo.Add(location);
        return Content(location.Id.ToString());
    }
    [HttpGet]
    [Route("GetLocations")]
    public IActionResult GetLocations()
    {
        var rawLocations = _locationRepo.GetAll(false, l => l.City, l => l.City.Country);
        var locations = _mapper.Map<List<LocationGet>>(rawLocations);

        return Json(locations);
    }

}
