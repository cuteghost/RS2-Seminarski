using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTO.AuthDTO;
using Repository.Interfaces;
using Services.FacebookService;
using Services.TokenHandlerService;

namespace Controllers.UserControllers;

[ApiController]
[Route("/api/[controller]")]
public class AuthController : Controller
{
    private readonly ILoginRepository _loginRepository;
    private readonly ITokenHandlerService _tokenHandlerService;
    private readonly IMapper _mapper;
    private readonly IFacebook _facebook;
    public AuthController(ILoginRepository loginRepository, ITokenHandlerService tokenHandlerService, IMapper mapper, IFacebook facebook)
    {
        _loginRepository = loginRepository;
        _tokenHandlerService = tokenHandlerService;
        _mapper = mapper;
        _facebook = facebook;

    }
    [HttpPost]
    [Route("login")]

    public async Task<IActionResult> LoginAsync(LoginDTO login)
    {
        var validUser = await _loginRepository.Login(login);
        if (validUser != null)
        {
            var tempUser = _mapper.Map<LoginDTO>(validUser);
            var loginResponse = await _tokenHandlerService.CreateTokenAsync(tempUser);
            return Content(loginResponse);
        }
        return Content("401");
    }

    [Authorize]
    [HttpGet]
    [Route("refresh-token")]
    public async Task<IActionResult> RefreshToken([FromHeader] string Authorization)
    {
        return Content(await _tokenHandlerService.RefreshTokenAsync(Authorization));
    }

    [HttpPost]
    [Route("facebook-login")]
    public async Task<IActionResult> FacebookLogin([FromBody] string accessToken)
    {
        var (isValid, userInfo) = await _facebook.ValidateFacebookAccessToken(accessToken);
        if (!isValid)
        {
            return Unauthorized("Invalid Facebook access token.");
        }
        return Json(userInfo);
    }
}
