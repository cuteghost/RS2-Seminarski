using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.AccommodationDTO;
using Services.TokenHandlerService;
using Repository.Interfaces;

namespace Controllers;
[ApiController]
[Route("/api/[controller]")]
public class AccommodationController : Controller
{
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IGenericRepository<Partner> _partnerRepo;
    private readonly ITokenHandlerService _tokenHandlerService;
    private readonly IMapper _mapper;
    public AccommodationController(IGenericRepository<Accommodation> accommodationRepo,ITokenHandlerService tokenHandlerService, 
                                   IGenericRepository<Partner> partnerRepo, IMapper mapper)
    {
        _accommodationRepo = accommodationRepo;
        _partnerRepo = partnerRepo;
        _tokenHandlerService = tokenHandlerService;
        _mapper = mapper;
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
    public async Task<IActionResult> Update([FromBody]AccommodationPATCH accommodationDto ) 
    {
        var accommodation = _mapper.Map<Accommodation>(accommodationDto);
        if (await _accommodationRepo.Update(c => c.Id == accommodation.Id, accommodation))
            return Content("OK");

        return Content("Not Found");
    }
    [HttpGet]
    [Route("GetAccommodations")]
    public IActionResult GetAccommodations()
    {
        var rawAccommodation = _accommodationRepo.GetAll();
        var accommodation = _mapper.Map<List<AccommodationGET>>(rawAccommodation);
        return Json(accommodation);
    }

}