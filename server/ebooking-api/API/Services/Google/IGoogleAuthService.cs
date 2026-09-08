using Models.Domain;
using Models.DTO.GoogleDTO;
using static Google.Apis.Auth.GoogleJsonWebSignature;

namespace Services.Google;

public interface IGoogleAuthService
{
    bool IsConfigured { get; }

    Task<BaseResponse<Payload>> GoogleSignIn(GoogleSignInVM model);

    Task<GoogleUserInfoResponse?> GetUserData(GoogleSignInVM model);
}
