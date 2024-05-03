using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Models.Domain;
using Models.DTO.UserDTO.Administrator;
using Repository.Interfaces;
using Services.TokenHandlerService;

namespace API.Controllers.UserControllers;

[ApiController]
[Route("/api/[controller]")]
public class AdministratorController : Controller
{
    private readonly IGenericRepository<User> _userRepo;
    private readonly IAdministratorRepository _adminRepo;
    private readonly IMapper _mapper;
    private readonly ITokenHandlerService _tokenHandler;
    public AdministratorController(IGenericRepository<User> userRepo, IMapper mapper, ITokenHandlerService tokenHandlerService, IAdministratorRepository adminRepo)
    {
        _userRepo = userRepo;
        _mapper = mapper;
        _tokenHandler = tokenHandlerService;
        _adminRepo = adminRepo;

    }

    [Authorize]
    [HttpGet]
    [Route("GetCustomers")]
    public async Task<IActionResult> GetCustomers([FromHeader] string Authorization)
    {
        if (_tokenHandler.GetAdministratorIdFromJWT(Authorization) == null) return Unauthorized();
        return Json(await _adminRepo.GetAllCustomers());
    }

    [Authorize]
    [HttpGet]
    [Route("GetPartners")]
    public async Task<IActionResult> GetPartners([FromHeader] string Authorization)
    {
        if (_tokenHandler.GetAdministratorIdFromJWT(Authorization) == null) return Unauthorized();
        return Json(await _adminRepo.GetAllPartners());
    }

    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> RegisterAdministrator([FromBody] AdministratorPOST userDto)
    {
        var user = _mapper.Map<User>(userDto);
        await _userRepo.Add(user);

        return Content("Ok");
    }

    [HttpGet]
    [Route("GetUsers")]
    public async Task<IActionResult> GetUsers()
    {
        return Json(await _userRepo.GetAll(includeDeleted: false));
    }

    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> DeleteUser([FromRoute] Guid id)
    {
        if (await _userRepo.Delete(u => u.Id == id))
            return Content("OK");
        else
            return Content("Not Found");
    }

    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> UpdateUser([FromBody] AdministratorPATCH userDto)
    {

        var user = _mapper.Map<User>(userDto);
        if (await _userRepo.Update(c => c.Id == user.Id, user))
            return Content("OK");
        else
            return Content("Not Found");
    }
}
