using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.Reflection;
using System.Text;
using Database;

namespace Seminarski.Database;

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
                return reader.ReadToEnd();
            }
        }
    }
    public static string ExtractConnectionString()
    {
        var assemblyName = Assembly.GetExecutingAssembly().GetName().Name;
        var embeddedAppSettingsJson = GetEmbeddedResource($"{assemblyName}.appsettings.json");
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
        if (string.IsNullOrWhiteSpace(dbConnectionString))
            throw new InvalidOperationException(
                "Connection string is empty. Set DB_SERVER, DB_NAME, DB_USER and DB_PASSWORD.");

        optionsBuilder.UseSqlServer(dbConnectionString);
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
