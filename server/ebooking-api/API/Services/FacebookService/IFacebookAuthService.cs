using Models.Domain;

namespace Services.FacebookService;

public interface IFacebookAuthService
{
    Task<BaseResponse<FacebookTokenValidationResponse>> ValidateFacebookToken(string accessToken);
    Task<BaseResponse<FacebookUserInfoResponse>> GetFacebookUserInformation(string accessToken);
}
