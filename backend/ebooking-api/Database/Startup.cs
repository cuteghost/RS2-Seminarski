using Microsoft.Extensions.DependencyInjection;
using TaxiHDbContext;

public class Startup
{
    static void Main()
    {
        var services = new ServiceCollection();
        
        string dbConnectionString = !string.IsNullOrWhiteSpace(ServiceRegistry.ReadFromEnv()) ? ServiceRegistry.ReadFromEnv() : ServiceRegistry.ExtractConnectionString() ;
        
        if (string.IsNullOrEmpty(dbConnectionString))
        {
            Console.WriteLine("ERROR: DB connection doesn't exist!");
            return;
        }
        ServiceRegistry.RegisterServices(services, dbConnectionString);
    }
}


