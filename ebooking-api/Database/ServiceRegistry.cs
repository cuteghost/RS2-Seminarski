using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.Reflection;
using System.Text;
using Database;

namespace TaxiHDbContext;

public static class ServiceRegistry
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
    public static string ExtractConnectionString()
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
        string dbConnectionString = configuration.GetConnectionString("DBConnection") ?? "";

        return dbConnectionString;
    }
    public static void RegisterServices(IServiceCollection services, string dbConnectionString)
    {
        #region Database
        services.AddDbContext<ApplicationDbContext>(options =>
        {
            ConfigureDbContext(options, dbConnectionString);
        });
        #endregion
    }
    public static void ConfigureDbContext(DbContextOptionsBuilder optionsBuilder, string dbConnectionString)
    {
        try
        {
            if (dbConnectionString != null)
            {
                optionsBuilder.UseSqlServer(dbConnectionString);
                Console.WriteLine("INFO: Connection with the database established successfully!");
            }
            else
            {
                Console.WriteLine("ERROR: Unable to connect to the SQL server.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"ERROR: Configuration of DBContext failed!\n{ ex}");
            throw;
        }
        
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
}
