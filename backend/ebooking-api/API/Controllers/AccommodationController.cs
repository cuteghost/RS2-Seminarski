using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.AccommodationDTO;
using Authentication.Services.TokenHandlerService;
using Repository.Interfaces;
using Services.LocationService;
using Models.DTO.AccommodationsDTO.SearchDTO;

namespace Controllers;
[ApiController]
[Route("/api/[controller]")]
public class AccommodationController : Controller
{
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IGenericRepository<Partner> _partnerRepo;
    private readonly ITokenHandlerService _tokenHandlerService;
    private readonly IMapper _mapper;
    private readonly ILocationService _locationService;

    public AccommodationController(IGenericRepository<Accommodation> accommodationRepo,ITokenHandlerService tokenHandlerService, 
                                   IGenericRepository<Partner> partnerRepo, IMapper mapper, ILocationService locationService)
    {
        _accommodationRepo = accommodationRepo;
        _partnerRepo = partnerRepo;
        _tokenHandlerService = tokenHandlerService;
        _mapper = mapper;
        _locationService = locationService;
    }
    [HttpPost]
    [Route("Add")]
    [Authorize]
    public async Task<IActionResult> Add([FromBody]AccommodationPOST accommodationDto, [FromHeader] string Authorization)
    {
        var partnerId = _tokenHandlerService.GetPartnerIdFromJWT(Authorization);
        var partner = await _partnerRepo.Get(c => c.Id == partnerId, false);
        if (partner == null)
            return BadRequest("Partner doens't exist!");

        var accommodation = _mapper.Map<Accommodation>(accommodationDto);
        accommodation.OwnerId = partner.Id;

        await _accommodationRepo.Add(accommodation);

        return Content("Ok");
    }

    [HttpPatch]
    [Route("Update")]
    [Authorize]
    public async Task<IActionResult> Update([FromBody] AccommodationPATCH accommodationDto, [FromHeader] string Authorization ) 
    {
        var partnerId = _tokenHandlerService.GetPartnerIdFromJWT(Authorization);
        var accommodation = _mapper.Map<Accommodation>(accommodationDto);
        accommodation.OwnerId = partnerId;
        if (await _accommodationRepo.Update(c => c.Id == accommodation.Id, accommodation, c => c.AccommodationImages, c => c.AccommodationDetails, c => c.Owner))
            return Content("OK");

        return NotFound("Not Found");
    }

    [HttpGet]
    [Route("GetAccommodations")]
    async public Task<IActionResult> GetAccommodations()
    {
        var rawAccommodations = await _accommodationRepo.GetAll(false, c => c.AccommodationDetails, c => c.AccommodationImages, c => c.Location);
        var accommodations = _mapper.Map<List<AccommodationGET>>(rawAccommodations);
        return Json(accommodations);
    }

    [HttpGet]
    [Authorize]
    [Route("GetMyAccommodation")]
    public async Task<IActionResult> GetMyAccommodation([FromHeader] string Authorization)
    {
        var partnerId = _tokenHandlerService.GetPartnerIdFromJWT(Authorization);
        if (partnerId == Guid.Empty)
            return Unauthorized();
        var rawAccommodation = await _accommodationRepo.GetAll(c => c.OwnerId == partnerId, false,c => c.AccommodationDetails, c => c.AccommodationImages, c => c.Location );
        var accommodation = _mapper.Map<List<AccommodationGET>>(rawAccommodation);
        return Json(accommodation);
    }

    [Authorize]
    [HttpGet]
    [Route("GetAccommodationById")]
    public async Task<IActionResult> GetAccommodationById([FromQuery] Guid id)
    {
        var rawAccommodation = await _accommodationRepo.Get(c => c.Id == id, false, c => c.AccommodationDetails, c => c.AccommodationImages, c => c.Location, c => c.Owner.User);
        if (rawAccommodation == null)
            return NotFound();
        var accommodation = _mapper.Map<AccommodationGET>(rawAccommodation);
        accommodation.OwnerId = rawAccommodation.Owner.User.Id;
        return Json(accommodation);
    }

    //[Authorize]
    [HttpGet]
    [Route("GetNearby")]
    public async Task<IActionResult> GetNearby([FromQuery] double latitude, [FromQuery] double longitude)
    {
        var rawAccommodation = await _accommodationRepo.GetAll(false, c => c.Location, c=> c.AccommodationDetails, c=> c.AccommodationImages);
        var accommodation = _mapper.Map<List<AccommodationGET>>(rawAccommodation);
        var nearbyAccommodation = accommodation.Where(c => _locationService.CalculateDistance(latitude, longitude, c.Location.Latitude, c.Location.Longitude) < 10).ToList();
        return Json(nearbyAccommodation);
    }
    //[HttpPost]
    //[Route("Search")]
    //public async Task<IActionResult> SearchAccommodations([FromBody] SearchDTO searchDto)
    //{
    //    var rawAccommodation = await _accommodationRepo.GetAll(false, c => c.Location, c => c.AccommodationDetails, c => c.AccommodationImages);
    //    var accommodation = _mapper.Map<List<AccommodationGET>>(rawAccommodation);
    //    var searchResult = accommodation.Where(c => c.Location.Country == searchDto.Country && c.Location.City == searchDto.City).ToList();
    //    return Json(searchResult);
    //}

}