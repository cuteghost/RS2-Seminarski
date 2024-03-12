using Models.DTO.FacebookDTO;

namespace Services.FacebookService;

public interface IFacebook
{
    public Task<(bool IsValid, UserInfo UserInfo)> ValidateFacebookAccessToken(string accessToken);
}
