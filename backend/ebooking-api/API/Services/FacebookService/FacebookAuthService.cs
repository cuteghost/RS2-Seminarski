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


        public async Task<BaseResponse<FacebookTokenValidationResponse>> ValidateFacebookToken(string accessToken)
        {
            try
            {
                string TokenValidationUrl = _facebookAuthConfig.TokenValidationUrl;
                var url = string.Format(TokenValidationUrl, accessToken, _facebookAuthConfig.AppId, _facebookAuthConfig.AppSecret);
                var response = await _httpClient.GetAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    var responseAsString = await response.Content.ReadAsStringAsync();

                    var tokenValidationResponse = JsonConvert.DeserializeObject<FacebookTokenValidationResponse>(responseAsString);
                    return new BaseResponse<FacebookTokenValidationResponse>("Success", true, tokenValidationResponse);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return new BaseResponse<FacebookTokenValidationResponse>("Failed to get response", false, null);

        }

        public async Task<BaseResponse<FacebookUserInfoResponse>> GetFacebookUserInformation(string accessToken)
        {
            try
            {
                string userInfoUrl = _facebookAuthConfig.UserInfoUrl;
                string url = string.Format(userInfoUrl, accessToken);

                var response = await _httpClient.GetAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    var responseAsString = await response.Content.ReadAsStringAsync();
                    var userInfoResponse = JsonConvert.DeserializeObject<FacebookUserInfoResponse>(responseAsString);
                    return new BaseResponse<FacebookUserInfoResponse>("Success", true, userInfoResponse);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return new BaseResponse<FacebookUserInfoResponse>("Failed to get response", false, null);

        }

    }
}
