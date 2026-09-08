using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Database.Data.Seed;

/// <summary>
/// Priprema bazu pri pokretanju API-ja: primijeni migracije (čime se kreira i seed) pa upiši
/// seed slike. Zamjenjuje raniji <c>restore.sh</c> koji je vraćao <c>Database.bak</c> unutar
/// SQL Server kontejnera.
/// </summary>
public static class DatabaseInitializer
{
    /// <summary>
    /// Docker healthcheck baze javi „healthy" čim SQL Server prihvati prvu prijavu, ali prva
    /// konekcija nakon toga zna pasti dok se instanca do kraja ne podigne. Zato ograničen broj
    /// ponovnih pokušaja umjesto pada cijelog servisa.
    /// </summary>
    private const int MaxAttempts = 10;

    private static readonly TimeSpan RetryDelay = TimeSpan.FromSeconds(5);

    public static async Task InitializeAsync(IServiceProvider services, CancellationToken cancellationToken = default)
    {
        using var scope = services.CreateScope();

        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var logger = scope.ServiceProvider
            .GetRequiredService<ILoggerFactory>()
            .CreateLogger(typeof(DatabaseInitializer));

        for (var attempt = 1; ; attempt++)
        {
            try
            {
                await context.Database.MigrateAsync(cancellationToken);
                logger.LogInformation("Migracije baze su primijenjene.");
                break;
            }
            catch (SqlException ex) when (attempt < MaxAttempts)
            {
                logger.LogWarning(ex,
                    "Baza još nije dostupna (pokušaj {Attempt}/{MaxAttempts}). Ponovni pokušaj za {Delay} sekundi.",
                    attempt, MaxAttempts, RetryDelay.TotalSeconds);
                await Task.Delay(RetryDelay, cancellationToken);
            }
        }

        await SeedImageInitializer.ApplyAsync(context, logger, cancellationToken);
        await BulkSeedInitializer.ApplyAsync(context, logger, cancellationToken);
    }
}
