using System.Reflection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Models.Domain;

namespace Database.Data.Seed;

/// <summary>
/// Upisuje fotografije seed smještaja i avatare seed korisnika u bazu, odmah nakon
/// <c>Database.Migrate()</c>.
///
/// <para>
/// Slike ne idu kroz <c>HasData</c> jer EF bajtove upisuje doslovno u migracioni fajl —
/// šezdeset fotografija bi značilo nekoliko megabajta generisanog izvornog koda koji se ne može
/// pregledati. Umjesto toga stoje kao <c>.jpg</c> fajlovi ugrađeni u <c>Database.dll</c>, a ovaj
/// inicijalizator ih upisuje u redove koje je seed ostavio praznim.
/// </para>
///
/// <para>
/// Idempotentan je: mijenja samo redove čije su slike još uvijek prazne, pa ponovno pokretanje
/// aplikacije ne pregazi slike koje je korisnik u međuvremenu postavio.
/// </para>
/// </summary>
public static class SeedImageInitializer
{
    private const string ResourceFolder = "Database.Data.Seed.Images.";

    /// <summary>Pet fotografija za svaki smještaj, redom kojim su smještaji seedovani.</summary>
    private static readonly string[][] AccommodationPhotos =
    {
        new[] { "vila-bazen.jpg", "dnevni-boravak-kamin.jpg", "spavaca-soba.jpg", "kupatilo-klasicno.jpg", "stepenice-mramor.jpg" },
        new[] { "dnevni-boravak-minimal.jpg", "spavaca-soba.jpg", "kupatilo-klasicno.jpg", "salon-luster.jpg", "kuca-eksterijer.jpg" },
        new[] { "apartman-suite.jpg", "salon-luster.jpg", "kupatilo-tamno.jpg", "dnevni-boravak-kamin.jpg", "stepenice-mramor.jpg" },
        new[] { "spavaca-soba.jpg", "dnevni-boravak-minimal.jpg", "kupatilo-klasicno.jpg", "kuca-eksterijer.jpg", "salon-luster.jpg" },
        new[] { "dnevni-boravak-kamin.jpg", "stepenice-mramor.jpg", "apartman-suite.jpg", "kupatilo-tamno.jpg", "spavaca-soba.jpg" },
        new[] { "kuca-eksterijer.jpg", "dnevni-boravak-minimal.jpg", "spavaca-soba.jpg", "kupatilo-klasicno.jpg", "salon-luster.jpg" },
        new[] { "salon-luster.jpg", "spavaca-soba.jpg", "kupatilo-klasicno.jpg", "dnevni-boravak-minimal.jpg", "kuca-eksterijer.jpg" },
        new[] { "vila-bazen.jpg", "stepenice-mramor.jpg", "apartman-suite.jpg", "kupatilo-tamno.jpg", "dnevni-boravak-kamin.jpg" },
        new[] { "dnevni-boravak-minimal.jpg", "apartman-suite.jpg", "spavaca-soba.jpg", "kupatilo-klasicno.jpg", "salon-luster.jpg" },
        new[] { "apartman-suite.jpg", "vila-bazen.jpg", "kupatilo-tamno.jpg", "stepenice-mramor.jpg", "dnevni-boravak-kamin.jpg" },
        new[] { "kuca-eksterijer.jpg", "dnevni-boravak-kamin.jpg", "spavaca-soba.jpg", "kupatilo-klasicno.jpg", "dnevni-boravak-minimal.jpg" },
        new[] { "vila-bazen.jpg", "apartman-suite.jpg", "stepenice-mramor.jpg", "kupatilo-tamno.jpg", "salon-luster.jpg" },
    };

    /// <summary>Avatar za svakog seed korisnika, redom kojim su korisnici seedovani.</summary>
    private static readonly string[] UserAvatars =
    {
        "avatar-admin.jpg",
        "avatar-dino.jpg",
        "avatar-ivana.jpg",
        "avatar-marko.jpg",
        "avatar-dea.jpg",
        "avatar-mobile.jpg",
        "avatar-lejla.jpg",
        "avatar-emir.jpg",
        "avatar-tarik.jpg",
    };

    public static async Task ApplyAsync(ApplicationDbContext context, ILogger logger, CancellationToken cancellationToken = default)
    {
        var updatedAccommodations = await FillAccommodationPhotos(context, cancellationToken);
        var updatedUsers = await FillUserAvatars(context, cancellationToken);

        if (updatedAccommodations == 0 && updatedUsers == 0)
        {
            logger.LogInformation("Seed slike su već upisane, preskačem.");
            return;
        }

        // Jedan SaveChangesAsync za oba skupa promjena — nema potrebe za eksplicitnom transakcijom.
        await context.SaveChangesAsync(cancellationToken);
        logger.LogInformation(
            "Upisane seed slike: {AccommodationCount} smještaja i {UserCount} korisničkih avatara.",
            updatedAccommodations, updatedUsers);
    }

    private static async Task<int> FillAccommodationPhotos(ApplicationDbContext context, CancellationToken cancellationToken)
    {
        var expectedIds = Enumerable.Range(1, AccommodationPhotos.Length)
            .Select(SeedIds.AccommodationImages)
            .ToList();

        // Filtriranje ide u SQL: dohvaćaju se samo seed redovi kojima je prva slika još prazna.
        // ApplicationDbContext nema DbSet za AccommodationImages - entitet je u modelu
        // preko navigacije sa Accommodation, pa se dohvaća kroz Set<T>().
        var rows = await context.Set<AccommodationImages>()
            .Where(images => expectedIds.Contains(images.AccommodationImagesId) && images.Image1.Length == 0)
            .ToListAsync(cancellationToken);

        foreach (var row in rows)
        {
            var number = expectedIds.IndexOf(row.AccommodationImagesId) + 1;
            var photos = AccommodationPhotos[number - 1];

            row.Image1 = ReadResource(photos[0]);
            row.Image2 = ReadResource(photos[1]);
            row.Image3 = ReadResource(photos[2]);
            row.Image4 = ReadResource(photos[3]);
            row.Image5 = ReadResource(photos[4]);
        }

        return rows.Count;
    }

    private static async Task<int> FillUserAvatars(ApplicationDbContext context, CancellationToken cancellationToken)
    {
        var expectedIds = Enumerable.Range(1, UserAvatars.Length)
            .Select(SeedIds.User)
            .ToList();

        var users = await context.Users
            .Where(user => expectedIds.Contains(user.Id) && (user.Image == null || user.Image.Length == 0))
            .ToListAsync(cancellationToken);

        foreach (var user in users)
        {
            var number = expectedIds.IndexOf(user.Id) + 1;
            user.Image = ReadResource(UserAvatars[number - 1]);
        }

        return users.Count;
    }

    internal static byte[] ReadResource(string fileName)
    {
        var assembly = Assembly.GetExecutingAssembly();
        using var stream = assembly.GetManifestResourceStream(ResourceFolder + fileName)
            ?? throw new InvalidOperationException(
                $"Seed slika '{fileName}' nije ugrađena u {assembly.GetName().Name}. " +
                "Provjeri EmbeddedResource stavku za Data/Seed/Images u Database.csproj.");

        using var buffer = new MemoryStream();
        stream.CopyTo(buffer);
        return buffer.ToArray();
    }
}
