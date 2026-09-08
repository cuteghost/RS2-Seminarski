using Models.Domain;

namespace Services.FacebookService;

public interface IFacebookAuthService
{
    bool IsConfigured { get; }

    string AppId { get; }

    Task<BaseResponse<FacebookTokenValidationResponse>> ValidateFacebookToken(string accessToken);
    Task<BaseResponse<FacebookUserInfoResponse>> GetFacebookUserInformation(string accessToken);
}
