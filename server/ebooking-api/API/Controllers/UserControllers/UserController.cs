using Database.Services.AccountService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.AuthDTO;
using Models.DTO.UserDTO;
using Repository.Interfaces;
using Services.CurrentUserService;

namespace Controllers.UserControllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class UserController : Controller
{
    private readonly IUserRepository _userRepo;
    private readonly ICurrentUserService _currentUser;
    private readonly IAccountService _accountService;

    public UserController(IUserRepository userRepo, ICurrentUserService currentUser, IAccountService accountService)
    {
        _userRepo = userRepo;
        _currentUser = currentUser;
        _accountService = accountService;
    }

    [HttpPatch]
    [Route("UpdateEmail")]
    public async Task<IActionResult> UpdateEmail([FromBody] UserEmailPATCH updateEmailDTO)
    {
        // Novi token je obavezan dio odgovora: stari nosi prethodnu email adresu u claimu.
        var token = await _userRepo.UpdateEmail(updateEmailDTO.email, updateEmailDTO.password, _currentUser.UserId);

        return Ok(new BaseResponse<TokenResponse>("Email address updated successfully.", new TokenResponse { Token = token }));
    }

    [HttpPatch]
    [Route("UpdatePassword")]
    public async Task<IActionResult> UpdatePassword([FromBody] UserPasswordPATCH updatePasswordDTO)
    {
        var token = await _userRepo.UpdatePassword(updatePasswordDTO.oldPassword, updatePasswordDTO.newPassword, _currentUser.UserId);

        return Ok(new BaseResponse<TokenResponse>("Password updated successfully.", new TokenResponse { Token = token }));
    }

    [HttpDelete]
    [Route("Delete")]
    public async Task<IActionResult> DeleteAccount()
    {
        await _accountService.DeleteOwnAccount(_currentUser.UserId);

        return Ok(new BaseResponse<object>("Account deleted successfully.", null));
    }
}
