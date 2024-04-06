using Microsoft.Extensions.DependencyInjection;
using PayPalContext;
using Services.Interfaces;

public class Startup
{
    static async Task Main(string[] args)
    {
        var services = new ServiceCollection();
        ConfigureServices(services);
        var serviceProvider = services.BuildServiceProvider();

        // Use the service
        var payPalService = serviceProvider.GetService<IPayPalService>();
        if (payPalService != null)
        {
            try
            {
                var accessToken = await payPalService.GetAccessTokenAsync();
                Console.WriteLine($"Access Token: {accessToken}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
            }
        }

    }

    private static void ConfigureServices(IServiceCollection services)
    {
        var payPalConfig = PayPalServiceRegistry.ExtractPayPalConfig();

        PayPalServiceRegistry.RegisterPayPalService(services, payPalConfig);
    }
}


