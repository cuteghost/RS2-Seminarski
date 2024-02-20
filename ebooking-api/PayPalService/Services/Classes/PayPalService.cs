using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Services.Interfaces;
using static PayPalContext.PayPalServiceRegistry;

namespace Services.Classes
{
    public class PayPalService : IPayPalService
    {
        private readonly PayPalConfig _config;

        public PayPalService(PayPalConfig config)
        {
            _config = config;
        }

        public async Task<string> GetAccessTokenAsync()
        {
            using var client = new HttpClient();
            var authToken = Convert.ToBase64String(Encoding.ASCII.GetBytes($"{_config.ClientId}:{_config.Secret}"));
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", authToken);

            var requestBody = new StringContent("grant_type=client_credentials", Encoding.UTF8, "application/x-www-form-urlencoded");

            var response = await client.PostAsync("https://api-m.sandbox.paypal.com/v1/oauth2/token", requestBody);
            var responseString = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                var jsonResponse = JsonConvert.DeserializeObject<dynamic>(responseString);
                return jsonResponse.access_token;
            }
            else
            {
                throw new Exception($"Failed to obtain access token. Status: {response.StatusCode}, Response: {responseString}");
            }
        }

    }
}
