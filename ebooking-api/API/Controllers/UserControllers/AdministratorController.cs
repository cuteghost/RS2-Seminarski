using AutoMapper;
using eBooking.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.UserDTO.Administrator;

namespace API.Controllers.UserControllers;

[ApiController]
[Route("/api/[controller]")]
public class AdministratorController : Controller
{
    private readonly IGenericRepository<User> _userRepo;
    private readonly IMapper _mapper;
    public AdministratorController(IGenericRepository<User> userRepo, IMapper mapper)
    {
        _userRepo = userRepo;
        _mapper = mapper;
    }

    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> RegisterAsCustomer([FromBody] AdministratorPOST userDto)
    {
        var user = _mapper.Map<User>(userDto);
        await _userRepo.Add(user);

        return Content("Ok");
    }
    [HttpGet]
    [Route("GetUsers")]
    public async Task<IActionResult> GetUsers()
    {
        return Json(await _userRepo.GetAll());
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
