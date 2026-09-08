using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Database.Data.Seed;

public static class BulkSeedInitializer
{
    private const int BatchSize = 2000;
    private const int TimeoutInSeconds = 600;
    private const int PhotosPerAccommodation = 5;

    private static readonly string[] Photos =
    {
        "apartman-suite.jpg",
        "dnevni-boravak-kamin.jpg",
        "dnevni-boravak-minimal.jpg",
        "kuca-eksterijer.jpg",
        "kupatilo-klasicno.jpg",
        "kupatilo-tamno.jpg",
        "salon-luster.jpg",
        "spavaca-soba.jpg",
        "stepenice-mramor.jpg",
        "vila-bazen.jpg",
    };

    private static readonly string[] MaleAvatars =
    {
        "avatar-admin.jpg", "avatar-dino.jpg", "avatar-marko.jpg", "avatar-emir.jpg", "avatar-tarik.jpg",
    };

    private static readonly string[] FemaleAvatars =
    {
        "avatar-ivana.jpg", "avatar-dea.jpg", "avatar-mobile.jpg", "avatar-lejla.jpg",
    };

    public static async Task ApplyAsync(
        ApplicationDbContext context,
        ILogger logger,
        CancellationToken cancellationToken = default)
    {
        var marker = SeedIds.User(BulkSeedData.LastUserNumber);
        if (await context.Users.AnyAsync(user => user.Id == marker, cancellationToken))
        {
            logger.LogInformation("Generisani seed podaci su već u bazi, preskačem.");
            return;
        }

        var set = BulkSeedData.Build();
        var photos = Photos.Select(SeedImageInitializer.ReadResource).ToArray();
        var maleAvatars = MaleAvatars.Select(SeedImageInitializer.ReadResource).ToArray();
        var femaleAvatars = FemaleAvatars.Select(SeedImageInitializer.ReadResource).ToArray();

        await using var connection = new SqlConnection(context.Database.GetConnectionString());
        await connection.OpenAsync(cancellationToken);
        await using var transaction = (SqlTransaction)await connection.BeginTransactionAsync(cancellationToken);

        try
        {
            await CopyAsync(connection, transaction, "Users", UserRows(set, maleAvatars, femaleAvatars), cancellationToken);
            await CopyAsync(connection, transaction, "Partners", PartnerRows(set), cancellationToken);
            await CopyAsync(connection, transaction, "Customers", CustomerRows(set), cancellationToken);
            await CopyAsync(connection, transaction, "Locations", LocationRows(set), cancellationToken);
            await CopyAsync(connection, transaction, "AccommodationDetails", DetailsRows(set), cancellationToken);
            await CopyAsync(connection, transaction, "AccommodationDetailsAmenities", AmenityRows(set), cancellationToken);
            await CopyAsync(connection, transaction, "AccommodationImages", ImageRows(set, photos), cancellationToken);
            await CopyAsync(connection, transaction, "Accommodations", AccommodationRows(set), cancellationToken);
            await CopyAsync(connection, transaction, "Reservations", ReservationRows(set), cancellationToken);
            await CopyAsync(connection, transaction, "Reviews", ReviewRows(set), cancellationToken);

            await transaction.CommitAsync(cancellationToken);
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            throw;
        }

        logger.LogInformation(
            "Upisani generisani seed podaci: {Users} korisnika, {Partners} partnera, {Customers} kupaca, " +
            "{Accommodations} smještaja, {Reservations} rezervacija i {Reviews} recenzija.",
            set.Users.Count, set.Partners.Count, set.Customers.Count,
            set.Accommodations.Count, set.Reservations.Count, set.Reviews.Count);
    }

    private static async Task CopyAsync(
        SqlConnection connection,
        SqlTransaction transaction,
        string destination,
        DataTable rows,
        CancellationToken cancellationToken)
    {
        using var copy = new SqlBulkCopy(connection, SqlBulkCopyOptions.Default, transaction)
        {
            DestinationTableName = destination,
            BatchSize = BatchSize,
            BulkCopyTimeout = TimeoutInSeconds,
        };

        foreach (DataColumn column in rows.Columns)
            copy.ColumnMappings.Add(column.ColumnName, column.ColumnName);

        await copy.WriteToServerAsync(rows, cancellationToken);
    }

    private static DataTable Table(params (string Name, Type Type)[] columns)
    {
        var table = new DataTable();
        foreach (var column in columns)
            table.Columns.Add(column.Name, column.Type);

        return table;
    }

    private static DataTable UserRows(BulkSeedSet set, byte[][] maleAvatars, byte[][] femaleAvatars)
    {
        var table = Table(
            ("Id", typeof(Guid)),
            ("Email", typeof(string)),
            ("Password", typeof(string)),
            ("DisplayName", typeof(string)),
            ("FirstName", typeof(string)),
            ("LastName", typeof(string)),
            ("BirthDate", typeof(DateTime)),
            ("Gender", typeof(short)),
            ("SocialLink", typeof(string)),
            ("Joined", typeof(DateTime)),
            ("Image", typeof(byte[])),
            ("IsActive", typeof(bool)),
            ("IsDeleted", typeof(bool)),
            ("Role", typeof(int)),
            ("TokenVersion", typeof(int)));

        foreach (var user in set.Users)
        {
            var avatars = user.Gender == 1 ? femaleAvatars : maleAvatars;
            table.Rows.Add(
                user.Id,
                user.Email,
                BulkSeedData.PasswordHash,
                user.DisplayName,
                user.FirstName,
                user.LastName,
                user.BirthDate,
                user.Gender,
                string.Empty,
                user.Joined,
                avatars[user.AvatarSlot % avatars.Length],
                true,
                false,
                user.Role,
                0);
        }

        return table;
    }

    private static DataTable PartnerRows(BulkSeedSet set)
    {
        var table = Table(
            ("Id", typeof(Guid)),
            ("UserId", typeof(Guid)),
            ("CountryId", typeof(Guid)),
            ("IsDeleted", typeof(bool)),
            ("TaxId", typeof(long)),
            ("TaxName", typeof(string)),
            ("PhoneNumber", typeof(long)));

        foreach (var partner in set.Partners)
            table.Rows.Add(partner.Id, partner.UserId, partner.CountryId, false, partner.TaxId, partner.TaxName, partner.PhoneNumber);

        return table;
    }

    private static DataTable CustomerRows(BulkSeedSet set)
    {
        var table = Table(
            ("Id", typeof(Guid)),
            ("UserId", typeof(Guid)),
            ("IsDeleted", typeof(bool)));

        foreach (var customer in set.Customers)
            table.Rows.Add(customer.Id, customer.UserId, false);

        return table;
    }

    private static DataTable LocationRows(BulkSeedSet set)
    {
        var table = Table(
            ("Id", typeof(Guid)),
            ("Longitude", typeof(double)),
            ("Latitude", typeof(double)),
            ("Address", typeof(string)),
            ("CityId", typeof(Guid)),
            ("IsDeleted", typeof(bool)));

        foreach (var location in set.Locations)
            table.Rows.Add(location.Id, location.Longitude, location.Latitude, location.Address, location.CityId, false);

        return table;
    }

    private static DataTable DetailsRows(BulkSeedSet set)
    {
        var table = Table(
            ("Id", typeof(Guid)),
            ("NumberOfBeds", typeof(int)),
            ("IsDeleted", typeof(bool)));

        foreach (var details in set.Details)
            table.Rows.Add(details.Id, details.NumberOfBeds, false);

        return table;
    }

    private static DataTable AmenityRows(BulkSeedSet set)
    {
        var table = Table(
            ("AccommodationDetailsId", typeof(Guid)),
            ("AmenityId", typeof(Guid)));

        foreach (var link in set.AmenityLinks)
            table.Rows.Add(link.AccommodationDetailsId, link.AmenityId);

        return table;
    }

    private static DataTable ImageRows(BulkSeedSet set, byte[][] photos)
    {
        var table = Table(
            ("AccommodationImagesId", typeof(Guid)),
            ("Image1", typeof(byte[])),
            ("Image2", typeof(byte[])),
            ("Image3", typeof(byte[])),
            ("Image4", typeof(byte[])),
            ("Image5", typeof(byte[])),
            ("IsDeleted", typeof(bool)));

        foreach (var accommodation in set.Accommodations)
        {
            var chosen = new object[PhotosPerAccommodation];
            for (var index = 0; index < PhotosPerAccommodation; index++)
                chosen[index] = photos[(accommodation.PhotoSlot + (index * 2)) % photos.Length];

            table.Rows.Add(
                accommodation.AccommodationImagesId,
                chosen[0], chosen[1], chosen[2], chosen[3], chosen[4],
                false);
        }

        return table;
    }

    private static DataTable AccommodationRows(BulkSeedSet set)
    {
        var table = Table(
            ("Id", typeof(Guid)),
            ("Name", typeof(string)),
            ("Status", typeof(bool)),
            ("AccommodationTypeId", typeof(Guid)),
            ("PricePerNight", typeof(double)),
            ("Description", typeof(string)),
            ("ReviewScore", typeof(decimal)),
            ("OwnerId", typeof(Guid)),
            ("LocationId", typeof(Guid)),
            ("AccommodationDetailsId", typeof(Guid)),
            ("AccommodationImagesId", typeof(Guid)),
            ("IsDeleted", typeof(bool)));

        foreach (var accommodation in set.Accommodations)
        {
            table.Rows.Add(
                accommodation.Id,
                accommodation.Name,
                true,
                accommodation.AccommodationTypeId,
                accommodation.PricePerNight,
                accommodation.Description,
                accommodation.ReviewScore,
                accommodation.OwnerId,
                accommodation.LocationId,
                accommodation.AccommodationDetailsId,
                accommodation.AccommodationImagesId,
                false);
        }

        return table;
    }

    private static DataTable ReservationRows(BulkSeedSet set)
    {
        var table = Table(
            ("Id", typeof(Guid)),
            ("NumberOfGuests", typeof(int)),
            ("StartDate", typeof(DateTime)),
            ("EndDate", typeof(DateTime)),
            ("AccommodationId", typeof(Guid)),
            ("CustomerId", typeof(Guid)),
            ("IsDeleted", typeof(bool)),
            ("IsRated", typeof(bool)),
            ("Status", typeof(int)),
            ("StatusChangedAt", typeof(DateTime)),
            ("StatusReason", typeof(string)),
            ("PricePerNight", typeof(decimal)),
            ("TotalPrice", typeof(decimal)));

        foreach (var reservation in set.Reservations)
        {
            table.Rows.Add(
                reservation.Id,
                reservation.NumberOfGuests,
                reservation.StartDate,
                reservation.EndDate,
                reservation.AccommodationId,
                reservation.CustomerId,
                false,
                reservation.IsRated,
                reservation.Status,
                reservation.StatusChangedAt,
                (object?)reservation.StatusReason ?? DBNull.Value,
                reservation.PricePerNight,
                reservation.TotalPrice);
        }

        return table;
    }

    private static DataTable ReviewRows(BulkSeedSet set)
    {
        var table = Table(
            ("Id", typeof(Guid)),
            ("CustomerId", typeof(Guid)),
            ("AccommodationId", typeof(Guid)),
            ("Rating", typeof(int)),
            ("Satisfaction", typeof(bool)),
            ("WouldRecommend", typeof(bool)),
            ("Comment", typeof(string)),
            ("IsDeleted", typeof(bool)));

        foreach (var review in set.Reviews)
        {
            table.Rows.Add(
                review.Id,
                review.CustomerId,
                review.AccommodationId,
                review.Rating,
                review.Satisfaction,
                review.WouldRecommend,
                review.Comment,
                false);
        }

        return table;
    }
}
