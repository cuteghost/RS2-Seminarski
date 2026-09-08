using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using PaymentApp.Models.PayPal;

namespace PaymentApp.Clients;

public sealed class PaypalClient
{
    private const int RawBodyLogLimit = 4000;

    private readonly HttpClient _httpClient;
    private readonly ILogger<PaypalClient> _logger;

    public string Mode { get; }
    public string ClientId { get; }
    public string ClientSecret { get; }

    public string BaseUrl => Mode == "Live"
        ? "https://api-m.paypal.com"
        : "https://api-m.sandbox.paypal.com";

    public PaypalClient(string clientId, string clientSecret, string mode, HttpClient httpClient,
                        ILogger<PaypalClient> logger)
    {
        ClientId = clientId;
        ClientSecret = clientSecret;
        Mode = mode;
        _httpClient = httpClient;
        _logger = logger;
    }

    private async Task<string> Authenticate()
    {
        var auth = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{ClientId}:{ClientSecret}"));

        var content = new List<KeyValuePair<string, string>>
        {
            new("grant_type", "client_credentials")
        };

        var request = new HttpRequestMessage
        {
            RequestUri = new Uri($"{BaseUrl}/v1/oauth2/token"),
            Method = HttpMethod.Post,
            Headers =
            {
                { "Authorization", $"Basic {auth}" }
            },
            Content = new FormUrlEncodedContent(content)
        };

        using var httpResponse = await _httpClient.SendAsync(request);

        var response = await Read<AuthResponse>(httpResponse, "PayPal login");

        if (string.IsNullOrEmpty(response.access_token))
            throw new PaypalApiException("PayPal login", (int)httpResponse.StatusCode, null, null, string.Empty,
                "PayPal did not return an access token. Check PAYPAL_CLIENT_ID, PAYPAL_SECRET_KEY and PAYPAL_ENV.");

        return response.access_token;
    }

    public async Task<CreateOrderResponse> CreateOrder(string value, string currency, string reference)
    {
        var accessToken = await Authenticate();

        var request = new CreateOrderRequest
        {
            intent = "CAPTURE",
            purchase_units = new List<PurchaseUnit>
            {
                new()
                {
                    reference_id = reference,
                    amount = new Amount
                    {
                        currency_code = currency,
                        value = value
                    }
                }
            }
        };

        _logger.LogInformation("Kreiranje PayPal narudžbe za plaćanje {Reference}: {Value} {Currency}, okruženje {Mode}.",
            reference, value, currency, Mode);

        using var httpRequest = new HttpRequestMessage(HttpMethod.Post, $"{BaseUrl}/v2/checkout/orders")
        {
            Content = JsonContent.Create(request),
            Headers = { Authorization = new AuthenticationHeaderValue("Bearer", accessToken) }
        };

        using var httpResponse = await _httpClient.SendAsync(httpRequest);

        var response = await Read<CreateOrderResponse>(httpResponse, "order creation");

        if (string.IsNullOrEmpty(response.id))
            throw new PaypalApiException("order creation", (int)httpResponse.StatusCode, null, null, string.Empty,
                "PayPal did not return an order identifier.");

        _logger.LogInformation("PayPal narudžba {OrderId} je kreirana u stanju {Status}.", response.id, response.status);

        return response;
    }

    public async Task<CaptureOrderResponse> CaptureOrder(string orderId)
    {
        var accessToken = await Authenticate();

        _logger.LogInformation("Naplata PayPal narudžbe {OrderId}.", orderId);

        using var httpRequest = new HttpRequestMessage(HttpMethod.Post, $"{BaseUrl}/v2/checkout/orders/{orderId}/capture")
        {
            Content = new StringContent("{}", Encoding.UTF8, "application/json"),
            Headers = { Authorization = new AuthenticationHeaderValue("Bearer", accessToken) }
        };

        using var httpResponse = await _httpClient.SendAsync(httpRequest);

        var response = await Read<CaptureOrderResponse>(httpResponse, "order capture");

        _logger.LogInformation("PayPal je narudžbu {OrderId} vratio u stanju {Status}.",
            orderId, response.status ?? "bez stanja");

        return response;
    }

    private async Task<T> Read<T>(HttpResponseMessage httpResponse, string operation)
    {
        var body = await httpResponse.Content.ReadAsStringAsync();
        var status = (int)httpResponse.StatusCode;

        if (!httpResponse.IsSuccessStatusCode)
        {
            _logger.LogError("PayPal je odbio {Operation}: HTTP {StatusCode}. Odgovor: {Body}",
                operation, status, ForLog(body));
            throw Describe(operation, status, body);
        }

        T? value;
        try
        {
            value = JsonSerializer.Deserialize<T>(body);
        }
        catch (JsonException e)
        {
            _logger.LogError(e, "Odgovor PayPala na {Operation} nije ispravan JSON. Odgovor: {Body}",
                operation, ForLog(body));
            throw new PaypalApiException(operation, status, null, null, body,
                $"PayPal's response to {operation} is not valid JSON.");
        }

        if (value == null)
        {
            _logger.LogError("Odgovor PayPala na {Operation} je prazan. Odgovor: {Body}", operation, ForLog(body));
            throw new PaypalApiException(operation, status, null, null, body,
                $"PayPal returned an empty response for {operation}.");
        }

        return value;
    }

    private PaypalApiException Describe(string operation, int status, string body)
    {
        string? name = null;
        string? issue = null;
        string? description = null;
        string? debugId = null;

        try
        {
            using var document = JsonDocument.Parse(body);
            var root = document.RootElement;

            if (root.TryGetProperty("name", out var nameElement))
                name = nameElement.GetString();

            if (root.TryGetProperty("error", out var errorElement))
                name = errorElement.GetString();

            if (root.TryGetProperty("message", out var messageElement))
                description = messageElement.GetString();

            if (root.TryGetProperty("error_description", out var errorDescriptionElement))
                description = errorDescriptionElement.GetString();

            if (root.TryGetProperty("debug_id", out var debugElement))
                debugId = debugElement.GetString();

            if (root.TryGetProperty("details", out var details)
                && details.ValueKind == JsonValueKind.Array
                && details.GetArrayLength() > 0)
            {
                var first = details[0];

                if (first.TryGetProperty("issue", out var issueElement))
                    issue = issueElement.GetString();

                if (first.TryGetProperty("description", out var detailDescriptionElement))
                    description = detailDescriptionElement.GetString();
            }
        }
        catch (JsonException e)
        {
            _logger.LogWarning(e, "Tijelo greške PayPala na {Operation} nije JSON.", operation);
        }

        var reason = issue ?? name;
        var text = new StringBuilder($"PayPal declined {operation} (HTTP {status})");

        if (!string.IsNullOrWhiteSpace(reason))
            text.Append($": {reason}");

        if (!string.IsNullOrWhiteSpace(description))
            text.Append($" — {description}");

        if (!string.IsNullOrWhiteSpace(debugId))
            text.Append($" [debug_id: {debugId}]");

        text.Append('.');

        return new PaypalApiException(operation, status, reason, debugId, body, text.ToString());
    }

    private static string ForLog(string body)
    {
        if (string.IsNullOrWhiteSpace(body))
            return "(prazno tijelo)";

        return body.Length > RawBodyLogLimit ? body[..RawBodyLogLimit] : body;
    }
}
