using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTO.AuthDTO;
using Models.DTO.FacebookDTO;
using Models.DTO.GoogleDTO;
using Repository.Interfaces;
using Services.FacebookService;
using Services.Google;
using Services.TokenHandlerService;

namespace Controllers.UserControllers;

[ApiController]
[Route("/api/[controller]")]
public class AuthController : Controller
{
    private readonly ILoginRepository _loginRepository;
    private readonly ITokenHandlerService _tokenHandlerService;
    private readonly IMapper _mapper;
    private readonly IFacebookAuthService _facebook;
    private readonly IGoogleAuthService _googleAuthService;

    public AuthController(ILoginRepository loginRepository, ITokenHandlerService tokenHandlerService, IMapper mapper, IFacebookAuthService facebook, IGoogleAuthService googleAuthService)
    {
        _loginRepository = loginRepository;
        _tokenHandlerService = tokenHandlerService;
        _mapper = mapper;
        _facebook = facebook;
        _googleAuthService = googleAuthService;
    }
    [HttpPost]
    [Route("login")]
    public async Task<IActionResult> LoginAsync(LoginDTO login)
    {

        var validUser = await _loginRepository.Login(login);
        if (validUser != null)
        {
            if (validUser.IsDeleted != true)
            {
                var loginResponse = await _tokenHandlerService.CreateTokenAsync(validUser);
                return Content(loginResponse);                
            }
        }
        return Unauthorized("401");
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
    public async Task<IActionResult> FacebookLogin([FromBody] FacebookSignInDTO model)
    {
        //Implement facebook login here
        var facebookResponse = await _facebook.ValidateFacebookToken(model.AccessToken);

        if (!facebookResponse.IsSuccess)
        {
            return Unauthorized("401");
        }
        else
        {
            var facebookUser = await _facebook.GetFacebookUserInformation(model.AccessToken);
            var validUser = await _loginRepository.FacebookLogin(facebookUser.Data);
            var loginResponse = await _tokenHandlerService.CreateTokenAsync(validUser);
            
            return Content(loginResponse);
        }
    }
    
    [HttpPost]
    [Route("google-login")]
    public async Task<IActionResult> GoogleLogin([FromBody] GoogleSignInVM model)
    {
        try
        {
            var loginPayload = await _googleAuthService.GoogleSignIn(model);
            var googleUser = await _googleAuthService.GetUserData(model);

            var validUser = await _loginRepository.GoogleLogin(loginPayload.Data, googleUser);

            var token = await _tokenHandlerService.CreateTokenAsync(validUser);
            
            return Content(token);
        }
        catch (Exception)
        {

            throw;
        }
    }

    [Authorize]
    [HttpGet]
    [Route("status")]
    public async Task<IActionResult> Status([FromHeader] string Authorization)
    {
        return Content(await _tokenHandlerService.RefreshTokenAsync(Authorization));
    }

}
