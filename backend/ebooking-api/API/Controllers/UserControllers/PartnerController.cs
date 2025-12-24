using AutoMapper;
using Repository.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.UserDTO.Partner;
using Authentication.Services.TokenHandlerService;

namespace API.Controllers.UserControllers;

[ApiController]
[Route("/api/[controller]")]
public class PartnerController : Controller
{
    private readonly IGenericRepository<Partner> _partnerRepo;
    private readonly IMapper _mapper;
    private readonly ITokenHandlerService _tokenHandler;
    private readonly IUserRepository _userRepository;
    public PartnerController(IGenericRepository<Partner> partnerRepo, IMapper mapper, ITokenHandlerService tokenHandler, IUserRepository userRepository)
    {
        _tokenHandler = tokenHandler;
        _partnerRepo = partnerRepo;
        _mapper = mapper;
        _userRepository = userRepository;
    }

    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> RegisterAsPartner([FromBody] PartnerPOST userDto, [FromHeader] string Authorization)
    {
        var user = _mapper.Map<Partner>(userDto);
        if (!await _partnerRepo.Add(user))
            return BadRequest();
        var userWithUpdatedRole = await _userRepository.UpdateRole(Role.PartnerRole, Authorization);
        if (userWithUpdatedRole == null)
            return BadRequest();
        return Content(await _tokenHandler.CreateTokenAsync(userWithUpdatedRole));

    }

    [HttpGet]
    [Route("PartnerDetails")]
    public async Task<IActionResult> GetPartnerDetails([FromHeader] string Authorization)
    {
        var userId = _tokenHandler.GetUserIdFromJWT(Authorization);
        if (userId == Guid.Empty)
            return BadRequest();
        var partner = await _partnerRepo.Get(c => c.UserId == userId, false);
        if (partner == null)
            return BadRequest();
        return Json(_mapper.Map<PartnerGET>(partner));
    }

    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> DeleteUser([FromRoute] Guid id)
    {
        if (await _partnerRepo.Delete(u => u.User.Id == id))
            return Content("OK");
        else
            return Content("Not Found");
    }

    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> UpdateUser([FromBody] PartnerPATCH partnerDto, [FromHeader] string Authorization)
    {
        var validPartnerId = _tokenHandler.GetPartnerIdFromJWT(Authorization);
        var partner = _mapper.Map<Partner>(partnerDto);
        if (await _partnerRepo.Update(c => (c.Id == partner.Id && partner.Id == validPartnerId), partner))
            return Content("OK");
        else
            return Content("Not Found");
    }
}
