using AutoMapper;
using eBooking.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.AccommodationDTO;

namespace Controllers;
[ApiController]
[Route("/api/[controller]")]
public class AccommodationController : Controller
{
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IMapper _mapper;
    public AccommodationController(IGenericRepository<Accommodation> accommodationRepo, IMapper mapper)
    {
        _accommodationRepo = accommodationRepo;
        _mapper = mapper;
    }
    [HttpPost]
    [Route("Add")]
    public IActionResult Add([FromBody]AccommodationPOST accommodationDto )
    {   
        var accommodation = _mapper.Map<Accommodation>(accommodationDto);
        _accommodationRepo.Add(accommodation);

        return Content("Ok");
    }
    [HttpGet]
    [Route("GetAccommodations")]
    public IActionResult GetCities()
    {
        var rawAccommodation = _accommodationRepo.GetAll();
        var accommodation = _mapper.Map<List<AccommodationGET>>(rawAccommodation);
        return Json(accommodation);
    }

}