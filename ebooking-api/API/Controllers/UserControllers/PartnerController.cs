using AutoMapper;
using eBooking.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.UserDTO.Partner;

namespace API.Controllers.UserControllers;

[ApiController]
[Route("/api/[controller]")]
public class PartnerController : Controller
{
    private readonly IGenericRepository<Partner> _userRepo;
    private readonly IMapper _mapper;
    public PartnerController(IGenericRepository<Partner> userRepo, IMapper mapper)
    {
        _userRepo = userRepo;
        _mapper = mapper;
    }

    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> RegisterAsCustomer([FromBody] PartnerPOST userDto)
    {
        var user = _mapper.Map<Partner>(userDto);
        await _userRepo.Add(user);

        return Content("Ok");
    }
    [HttpGet]
    [Route("GetUsers")]
    public async Task<IActionResult> GetUsers()
    {
        return Json(await _userRepo.GetAll());
    }
    [HttpGet]
    [Route("GetUser")]
    public async Task<IActionResult> GetById(Guid userId)
    {
        return Json(await _userRepo.GetById(c => c.User.Id == userId, false));
    }
    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> DeleteUser([FromRoute] Guid id)
    {
        if (await _userRepo.Delete(u => u.User.Id == id))
            return Content("OK");
        else
            return Content("Not Found");
    }
    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> UpdateUser([FromBody] PartnerPATCH userDto)
    {

        var user = _mapper.Map<Partner>(userDto);
        if (await _userRepo.Update(c => c.Id == user.Id, user))
            return Content("OK");
        else
            return Content("Not Found");
    }
}
