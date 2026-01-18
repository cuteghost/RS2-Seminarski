using Microsoft.Extensions.Options;
using Models.Domain;
using Models.DTO.GoogleDTO;
using Microsoft.Extensions.Logging;
using System.Net.Http.Headers;
using System.Text.Json;
using static Google.Apis.Auth.GoogleJsonWebSignature;

namespace Services.Google;

public class GoogleAuthService : IGoogleAuthService
{
    private const string PeopleApiUrl = "https://people.googleapis.com/v1/people/me?personFields=genders,birthdays";

    private static readonly HttpClient Client = new();

    private readonly GoogleAuthConfig _googleAuthConfig;
    private readonly ILogger<GoogleAuthService> _logger;

    public GoogleAuthService(IOptions<GoogleAuthConfig> googleAuthConfig, ILogger<GoogleAuthService> logger)
    {
        _googleAuthConfig = googleAuthConfig.Value;
        _logger = logger;
    }

    public bool IsConfigured => !string.IsNullOrWhiteSpace(_googleAuthConfig.ClientId);

    public async Task<BaseResponse<Payload>> GoogleSignIn(GoogleSignInVM model)
    {
        try
        {
            var payload = await ValidateAsync(model.IdToken, new ValidationSettings
            {
                Audience = new[] { _googleAuthConfig.ClientId }
            });

            return new BaseResponse<Payload>("Google accepted the token.", payload);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Google nije prihvatio priloženi token.");
            return new BaseResponse<Payload>("Google login failed.", null);
        }
    }

    public async Task<GoogleUserInfoResponse?> GetUserData(GoogleSignInVM model)
    {
        if (string.IsNullOrWhiteSpace(model.AccessToken))
            return null;

        try
        {
            var request = new HttpRequestMessage(HttpMethod.Get, PeopleApiUrl);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", model.AccessToken);

            var response = await Client.SendAsync(request);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("Google People API je odbio zahtjev sa statusom {Status}.", (int)response.StatusCode);
                return null;
            }

            var content = await response.Content.ReadAsStringAsync();

            return JsonSerializer.Deserialize<GoogleUserInfoResponse>(content);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Podaci o Google korisniku nisu dohvaćeni.");
            return null;
        }
    }
}
