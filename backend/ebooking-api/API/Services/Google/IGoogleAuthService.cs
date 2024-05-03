using Models.Domain;
using Models.DTO.GoogleDTO;
using Models.Models.Domain;
using static Google.Apis.Auth.GoogleJsonWebSignature;

namespace Services.Google;

public interface IGoogleAuthService
{
    Task<BaseResponse<Payload>> GoogleSignIn(GoogleSignInVM model);
    Task<GoogleUserInfoResponse> GetUserData(GoogleSignInVM model);
}
