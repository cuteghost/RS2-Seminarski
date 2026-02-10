using API.Exceptions;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.AuthDTO;
using Models.DTO.FacebookDTO;
using Models.DTO.GoogleDTO;
using Repository.Interfaces;
using Services.CurrentUserService;
using Services.FacebookService;
using Services.Google;
using Authentication.Services.TokenHandlerService;

namespace Controllers.UserControllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class AuthController : Controller
{
    private const string InactiveAccountMessage =
        "The account is deactivated, so login is not possible. Please contact an administrator.";

    private readonly ILoginRepository _loginRepository;
    private readonly ITokenHandlerService _tokenHandlerService;
    private readonly IMapper _mapper;
    private readonly IFacebookAuthService _facebook;
    private readonly IGoogleAuthService _googleAuthService;
    private readonly ICurrentUserService _currentUser;

    public AuthController(ILoginRepository loginRepository, ITokenHandlerService tokenHandlerService, IMapper mapper,
                          IFacebookAuthService facebook, IGoogleAuthService googleAuthService, ICurrentUserService currentUser)
    {
        _loginRepository = loginRepository;
        _tokenHandlerService = tokenHandlerService;
        _currentUser = currentUser;
        _mapper = mapper;
        _facebook = facebook;
        _googleAuthService = googleAuthService;
    }

    [AllowAnonymous]
    [HttpPost]
    [Route("login")]
    public async Task<IActionResult> LoginAsync(LoginDTO login)
    {
        var validUser = await _loginRepository.Login(login);

        // Ista poruka za nepostojeći nalog i za pogrešnu lozinku - razlikovanje bi otkrilo
        // koje email adrese postoje u sistemu.
        var refusal = RefuseSignIn(validUser, "Incorrect email address or password.");
        if (refusal != null)
            return refusal;

        var token = await _tokenHandlerService.CreateTokenAsync(validUser);
        if (token == null)
            throw new BusinessException("The account has not been assigned any role, so login is not possible. Please contact an administrator.");

        return Ok(new BaseResponse<TokenResponse>("Login successful.", new TokenResponse { Token = token }));
    }

    [HttpGet]
    [Route("refresh-token")]
    public async Task<IActionResult> RefreshToken()
    {
        var token = await _tokenHandlerService.RefreshTokenAsync(_currentUser.UserId);
        if (token == null)
            throw new NotFoundException("The logged-in account no longer exists, so the token cannot be refreshed.");

        return Ok(new BaseResponse<TokenResponse>("Token refreshed successfully.", new TokenResponse { Token = token }));
    }

    [AllowAnonymous]
    [HttpPost]
    [Route("facebook-login")]
    public async Task<IActionResult> FacebookLogin([FromBody] FacebookSignInDTO model)
    {
        if (string.IsNullOrWhiteSpace(model.AccessToken))
            throw new BusinessException("Facebook token is required.");

        if (!_facebook.IsConfigured)
            throw new BusinessException(
                "Facebook login is not configured on the server. Set FacebookAppId and FacebookAppSecret.");

        var validation = await _facebook.ValidateFacebookToken(model.AccessToken);
        if (validation.Data?.Data == null || !validation.Data.Data.IsValid)
            return Unauthorized(new ErrorResponse
            {
                StatusCode = StatusCodes.Status401Unauthorized,
                Message = "Facebook token was not accepted.",
            });

        if (!string.Equals(validation.Data.Data.AppId, _facebook.AppId, StringComparison.Ordinal))
            return Unauthorized(new ErrorResponse
            {
                StatusCode = StatusCodes.Status401Unauthorized,
                Message = "Facebook token was not issued for this application.",
            });

        var facebookUser = await _facebook.GetFacebookUserInformation(model.AccessToken);
        if (facebookUser.Data == null)
            throw new BusinessException("Facebook did not return user information.");

        if (string.IsNullOrWhiteSpace(facebookUser.Data.Email))
            throw new BusinessException(
                "The Facebook account has no email address, so it cannot be linked to an account in the app. Please log in with your email address and password.");

        var validUser = await _loginRepository.FacebookLogin(facebookUser.Data);
        var refusal = RefuseSignIn(validUser, "The Facebook account is not linked to any user.");
        if (refusal != null)
            return refusal;

        var token = await _tokenHandlerService.CreateTokenAsync(validUser);
        if (token == null)
            throw new BusinessException("The account has not been assigned any role, so login is not possible. Please contact an administrator.");

        return Ok(new BaseResponse<TokenResponse>("Login via Facebook account successful.", new TokenResponse { Token = token }));
    }

    [HttpPost]
    [Route("logout")]
    public async Task<IActionResult> Logout()
    {
        await _tokenHandlerService.InvalidateTokens(_currentUser.UserId);

        return Ok(new BaseResponse<object>("Logout successful. All tokens for this account are no longer valid.", null));
    }

    [AllowAnonymous]
    [HttpPost]
    [Route("google-login")]
    public async Task<IActionResult> GoogleLogin([FromBody] GoogleSignInVM model)
    {
        if (string.IsNullOrWhiteSpace(model.IdToken))
            throw new BusinessException("Google token is required.");

        if (!_googleAuthService.IsConfigured)
            throw new BusinessException(
                "Google login is not configured on the server. Set Google__ClientId.");

        var loginPayload = await _googleAuthService.GoogleSignIn(model);
        if (loginPayload.Data == null)
            return Unauthorized(new ErrorResponse
            {
                StatusCode = StatusCodes.Status401Unauthorized,
                Message = "Google token was not accepted.",
            });

        if (string.IsNullOrWhiteSpace(loginPayload.Data.Email))
            throw new BusinessException(
                "The Google account has no email address, so it cannot be linked to an account in the app.");

        var googleUser = await _googleAuthService.GetUserData(model);

        var validUser = await _loginRepository.GoogleLogin(loginPayload.Data, googleUser);
        var refusal = RefuseSignIn(validUser, "The Google account is not linked to any user.");
        if (refusal != null)
            return refusal;

        var token = await _tokenHandlerService.CreateTokenAsync(validUser);
        if (token == null)
            throw new BusinessException("The account has not been assigned any role, so login is not possible. Please contact an administrator.");

        return Ok(new BaseResponse<TokenResponse>("Login via Google account successful.", new TokenResponse { Token = token }));
    }

    private IActionResult RefuseSignIn(User user, string unknownAccountMessage)
    {
        if (user == null || user.IsDeleted)
            return Unauthorized(new ErrorResponse
            {
                StatusCode = StatusCodes.Status401Unauthorized,
                Message = unknownAccountMessage,
            });

        if (!user.IsActive)
            return Unauthorized(new ErrorResponse
            {
                StatusCode = StatusCodes.Status401Unauthorized,
                Message = InactiveAccountMessage,
            });

        return null;
    }

    [HttpGet]
    [Route("status")]
    public async Task<IActionResult> Status()
    {
        var token = await _tokenHandlerService.RefreshTokenAsync(_currentUser.UserId);
        if (token == null)
            throw new NotFoundException("The logged-in account no longer exists, so the token cannot be refreshed.");

        return Ok(new BaseResponse<TokenResponse>("Login is still valid.", new TokenResponse { Token = token }));
    }
}
