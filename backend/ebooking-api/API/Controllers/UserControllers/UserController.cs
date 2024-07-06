using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTO.UserDTO;
using Models.Models.DTO.UserDTO;
using Repository.Interfaces;
using Authentication.Services.TokenHandlerService;

namespace Controllers.UserControllers;

[ApiController]
[Route("/api/[controller]")]
public class UserController : Controller
{
    private readonly IUserRepository _userRepo;
    public UserController(IUserRepository userRepo)
    {
        _userRepo = userRepo;
    }

    [Authorize]
    [HttpPatch]
    [Route("UpdateEmail")]
    public async Task<IActionResult> UpdateEmail([FromBody] UserEmailPATCH updateEmailDTO, [FromHeader] string Authorization)
    {
        var email = updateEmailDTO.email;
        var password = updateEmailDTO.password;
        var result = await _userRepo.UpdateEmail(email, password, Authorization);
        if (result != "No user" && result != "Wrong password supplied")
            return Content(result);
        else
            return Unauthorized(result);
    }

    [Authorize]
    [HttpPatch]
    [Route("UpdatePassword")]
    public async Task<IActionResult> UpdatePassword([FromBody] UserPasswordPATCH updatePasswordDTO, [FromHeader] string Authorization)
    {
        var oldPassword = updatePasswordDTO.oldPassword;
        var newPassword = updatePasswordDTO.newPassword;
        var result = await _userRepo.UpdatePassword(oldPassword, newPassword, Authorization);
        if (result != "No user" && result != "Wrong password supplied")
            return Content(result);
        else
            return Unauthorized(result);
    }
}
