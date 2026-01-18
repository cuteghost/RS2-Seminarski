using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using Models.Domain;

namespace Services.FacebookService
{
    public class FacebookAuthService : IFacebookAuthService
    {

        private readonly HttpClient _httpClient;
        private readonly FacebookAuthConfig _facebookAuthConfig;

        public FacebookAuthService(
            IHttpClientFactory httpClientFactory,
            IConfiguration configuration,
            IOptions<FacebookAuthConfig> facebookAuthConfig)
        {
            _httpClient = httpClientFactory.CreateClient("Facebook");
            _facebookAuthConfig = facebookAuthConfig.Value;
        }


        public string AppId => _facebookAuthConfig.AppId;

        public bool IsConfigured =>
            !string.IsNullOrWhiteSpace(_facebookAuthConfig.AppId) &&
            !string.IsNullOrWhiteSpace(_facebookAuthConfig.AppSecret) &&
            !string.IsNullOrWhiteSpace(_facebookAuthConfig.TokenValidationUrl) &&
            !string.IsNullOrWhiteSpace(_facebookAuthConfig.UserInfoUrl);

        public async Task<BaseResponse<FacebookTokenValidationResponse>> ValidateFacebookToken(string accessToken)
        {
            {
                string TokenValidationUrl = _facebookAuthConfig.TokenValidationUrl;
                var url = string.Format(TokenValidationUrl, accessToken, _facebookAuthConfig.AppId, _facebookAuthConfig.AppSecret);
                var response = await _httpClient.GetAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    var responseAsString = await response.Content.ReadAsStringAsync();

                    var tokenValidationResponse = JsonConvert.DeserializeObject<FacebookTokenValidationResponse>(responseAsString);
                    return new BaseResponse<FacebookTokenValidationResponse>("Success", tokenValidationResponse);
                }
            }
            return new BaseResponse<FacebookTokenValidationResponse>("Facebook did not accept the token validation request.", null);

        }

        public async Task<BaseResponse<FacebookUserInfoResponse>> GetFacebookUserInformation(string accessToken)
        {
            {
                string userInfoUrl = _facebookAuthConfig.UserInfoUrl;
                string url = string.Format(userInfoUrl, accessToken);

                var response = await _httpClient.GetAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    var responseAsString = await response.Content.ReadAsStringAsync();
                    var userInfoResponse = JsonConvert.DeserializeObject<FacebookUserInfoResponse>(responseAsString);
                    return new BaseResponse<FacebookUserInfoResponse>("Success", userInfoResponse);
                }
            }
            return new BaseResponse<FacebookUserInfoResponse>("Facebook did not return user information.", null);

        }

    }
}
