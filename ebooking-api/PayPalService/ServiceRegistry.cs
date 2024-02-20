using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Services.Interfaces;
using Services.Classes;
using System.Reflection;
using System.Text;


namespace PayPalContext;

public static class PayPalServiceRegistry
{
    public static string GetEmbeddedResource(string resourceName)
    {
        var assembly = Assembly.GetExecutingAssembly();

        using (var stream = assembly.GetManifestResourceStream(resourceName))
        {
            if (stream == null)
            {
                throw new InvalidOperationException($"Resource '{resourceName}' not found in assembly '{assembly.FullName}'.");
            }

            using (StreamReader reader = new StreamReader(stream))
            {
                var res = reader.ReadToEnd();
                Console.WriteLine(res);
                return res;
            }
        }
    }
    public static PayPalConfig ExtractPayPalConfig()
    {
        var assemblyName = Assembly.GetExecutingAssembly().GetName().Name;
        var embeddedAppSettingsJson = GetEmbeddedResource($"{ assemblyName }.appsettings.json");
        var host = Host.CreateDefaultBuilder()
            .ConfigureAppConfiguration((context, config) =>
            {
                config.AddJsonStream(new MemoryStream(Encoding.UTF8.GetBytes(embeddedAppSettingsJson)));
            })
            .Build();

        var configuration = host.Services.GetRequiredService<IConfiguration>();
        var clientId = configuration["PayPalOptions:ClientId"] ?? throw new InvalidOperationException("PayPal ClientId is not configured");
        var secret = configuration["PayPalOptions:ClientSecret"] ?? throw new InvalidOperationException("PayPal Secret is not configured");
        var mode = configuration["PayPalOptions:Mode"] ?? throw new InvalidOperationException("PayPal Mode is not configured");
        return new PayPalConfig(clientId, secret, mode);
    }
    public static void RegisterPayPalService(IServiceCollection services, PayPalConfig payPalConfig)
    {
        #region PayPal
        services.AddSingleton(payPalConfig);
        services.AddScoped<IPayPalService, PayPalService>();
        #endregion
    }

    public static string ReadFromEnv()
    { 
        var dbServer = Environment.GetEnvironmentVariable("DB_SERVER");
        if (string.IsNullOrEmpty(dbServer))
            return "";
        var dbPort = Environment.GetEnvironmentVariable("DB_PORT");
        if (string.IsNullOrEmpty(dbPort))
            dbPort = "1433";
        var dbName = Environment.GetEnvironmentVariable("DB_NAME");
        if (string.IsNullOrEmpty(dbName))
            return "";
        var dbUser = Environment.GetEnvironmentVariable("DB_USER");
        if (string.IsNullOrEmpty(dbUser))
            return "";
        var dbPassword = Environment.GetEnvironmentVariable("DB_PASSWORD");
        if (string.IsNullOrEmpty(dbPassword))
            return "";
        return $"Server={dbServer},{dbPort};database={dbName};User Id={dbUser};Password={dbPassword};TrustServerCertificate=true;";
    }

    public class PayPalConfig
    {
        public string ClientId { get; }
        public string Secret { get; }
        public string Mode { get; }

        public PayPalConfig(string clientId, string secret, string mode)
        {
            ClientId = clientId;
            Secret = secret;
            Mode = mode;
        }
    }
}
