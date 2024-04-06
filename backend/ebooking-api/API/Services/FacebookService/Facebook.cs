using Services.FacebookService;
using Models.DTO.FacebookDTO;
using Newtonsoft.Json;

namespace Services.FacebookService;

public class Facebook : IFacebook
{
    public async Task<(bool IsValid, UserInfo UserInfo)> ValidateFacebookAccessToken(string accessToken)
    {
        var client = new HttpClient();
        var validateTokenEndpoint = $"https://graph.facebook.com/debug_token?input_token={accessToken}&access_token={accessToken}";
        var response = await client.GetAsync(validateTokenEndpoint);
        if (!response.IsSuccessStatusCode)
        {
            return (false, null);
        }

        var content = await response.Content.ReadAsStringAsync();
        var validationResponse = JsonConvert.DeserializeObject<FacebookTokenValidation>(content);

        if (!validationResponse.Data.IsValid)
        {
            return (false, null);
        }

        // Optionally, retrieve user info
        var userInfoEndpoint = $"https://graph.facebook.com/me?fields=id,name,email&access_token={accessToken}";
        response = await client.GetAsync(userInfoEndpoint);
        content = await response.Content.ReadAsStringAsync();
        var userInfo = JsonConvert.DeserializeObject<UserInfo>(content);

        return (true, userInfo);
    }

}
