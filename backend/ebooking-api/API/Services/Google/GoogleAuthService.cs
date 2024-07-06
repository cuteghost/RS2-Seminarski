using Azure.Core;
using Microsoft.Extensions.Options;
using Models.Domain;
using Models.DTO.GoogleDTO;
using Models.Models.Domain;
using Repository.Interfaces;
using Authentication.Services.TokenHandlerService;
using System.Net.Http.Headers;
using System.Text.Json;
using static Google.Apis.Auth.GoogleJsonWebSignature;


namespace Services.Google;

public class GoogleAuthService : IGoogleAuthService
{
    private readonly GoogleAuthConfig _googleAuthConfig;
    private readonly ICustomerRepository _customerRepository;
    private readonly ITokenHandlerService _tokenHandlerService;

    public GoogleAuthService(IOptions<GoogleAuthConfig> googleAuthConfig,
                             ICustomerRepository customerRepository,
                             ITokenHandlerService tokenHandlerService
        )
    {
        _googleAuthConfig = googleAuthConfig.Value;
        _customerRepository = customerRepository;
        _tokenHandlerService = tokenHandlerService;
    }

    public async Task<BaseResponse<Payload>> GoogleSignIn(GoogleSignInVM model)
    {

        Payload payload = new();

        try
        {
            payload = await ValidateAsync(model.IdToken, new ValidationSettings
            {
                Audience = new[] { _googleAuthConfig.ClientId }
            });

        }
        catch (Exception ex)
        {
            return new BaseResponse<Payload>("Failed to get a response.", false, null);
        }


        return new BaseResponse<Payload>("Success", true, payload);
    }

    public async Task<GoogleUserInfoResponse> GetUserData(GoogleSignInVM model)
    { 
        HttpClient client = new HttpClient();
        var request = new HttpRequestMessage(HttpMethod.Get, "https://people.googleapis.com/v1/people/me?personFields=genders,birthdays");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", model.AccessToken);
        var response = await client.SendAsync(request);
        
        var content = await response.Content.ReadAsStringAsync();
        var userInfo = JsonSerializer.Deserialize<GoogleUserInfoResponse>(content);
        
        return userInfo;
    }
}