using System.Globalization;
using Microsoft.EntityFrameworkCore;
using Models.Domain;

namespace Database.Data.Seed;

/// <summary>
/// Početni podaci baze. Poziva se iz <see cref="ApplicationDbContext.OnModelCreating"/> pa se
/// cijeli seed primjenjuje kroz migraciju — <c>Database.Migrate()</c> na startupu API-ja kreira
/// šemu i ubacuje ove redove. Time je zamijenjen raniji <c>Database.bak</c> restore.
///
/// <para>
/// <b>Sve vrijednosti moraju biti determinističke.</b> Bez <see cref="Guid.NewGuid"/>,
/// bez <c>DateTime.UtcNow</c> i bez <c>Random</c> — inače EF pri svakom scaffoldovanju vidi
/// promjenu seeda i generiše migraciju koja briše i ponovo ubacuje sve redove.
/// </para>
///
/// <para>
/// Binarne kolone (fotografije smještaja, avatari korisnika) se ovdje seeduju kao <b>prazni</b>
/// nizovi bajtova; puni ih <see cref="SeedImageInitializer"/> odmah nakon migracije, iz fajlova
/// ugrađenih u <c>Database.dll</c>. Razlog: <c>HasData</c> zapisuje bajtove doslovno u migraciju,
/// pa bi 60 fotografija naraslo migracioni fajl na nekoliko megabajta izvornog koda.
/// </para>
/// </summary>
public static class SeedData
{
    /// <summary>
    /// PBKDF2-HMAC-SHA256 zapisi lozinke <c>Stringst</c> za seed naloge, redom kojim su korisnici
    /// navedeni u <see cref="Users"/>.
    ///
    /// <para>
    /// <c>HashService.Hash</c> se ovdje ne može pozvati: on generiše nasumičnu so pa bi seed pri
    /// svakom pokretanju dao drugu vrijednost i EF bi generisao novu migraciju. Zato su zapisi
    /// unaprijed izračunati, svaki sa svojom soli izvedenom iz email adrese naloga
    /// (<c>SHA256("ebooking-seed:" + email)</c>, prvih 16 bajtova), sa istim brojem iteracija
    /// koji koristi <c>HashService</c>. Provjera pri prijavi ide kroz <c>HashService.Verify</c>.
    /// </para>
    /// </summary>
    private static readonly string[] SeedPasswordHashes =
    {
        "pbkdf2-sha256$210000$F4sKc/vBcNAHlTczfUeA3g==$LUTXGVXtMq8Uur6S3ASNUONf7T+432LDByBNv1dMKsE=", // admin@ebooking.com
        "pbkdf2-sha256$210000$UhC9GXZqavEsAGJn9zbRwQ==$Rz2+XiH0Ui9683w0xuUefPSLOzrk5gGbm+4vOwdHykk=", // dude@email.com
        "pbkdf2-sha256$210000$XdfzQkcLsN4YQlSCpg/gcg==$WPuYCvaok41trGvT2ncbpeakLOUnHdW9JJfuJbEUnug=", // adriatic@email.com
        "pbkdf2-sha256$210000$5IljL8kifIRsrp9674xXzA==$XMI04NeoIRRkOurPvdwsX3097utpIs65NgCcP0UKGmo=", // alpine@email.com
        "pbkdf2-sha256$210000$sUfGRW2b3aYL9DiDBgsznw==$G5PH9AH2Tr6j4UeZKvbdK7t19AniWgjnpOT0qikPb8Q=", // dea@email.com
        "pbkdf2-sha256$210000$q+yfAiHLdAve+zlMAQ+9iQ==$iL61ES5hCKjQ3+qktR15LXekmOtHQGi/ioQf9PmnwmM=", // mobile@ebooking.com
        "pbkdf2-sha256$210000$lFIW5xtQMv5VWfNw1rVLLw==$2tU7BEZVNV0mynJBhoy7fCd4TtcyOmAHzeHJbqW7N54=", // lejla@email.com
        "pbkdf2-sha256$210000$BCJh96cpPJYZL96P4l4dmQ==$P8f57xgxkL9QiVulZ6Ve//gVw2elhzijjrsyV4+qpKk=", // emir@email.com
        "pbkdf2-sha256$210000$71wU3gNAAjy7UFRJpDT/hQ==$6VdEE7A/qJpvX3NpYeIkzvHmRbfVB69QOKUiwsy/luU=", // tarik@email.com
    };

    internal const int CountryCount = 6;
    internal const int CityCount = 10;
    internal const int UserCount = 9;
    internal const int AccommodationCount = 12;
    internal const int CustomerCount = 5;
    internal const int PartnerCount = 3;
    internal const int ReservationsPerAccommodation = 5;
    internal const int ReviewsPerAccommodation = 2;
    private const int MaximumRating = 10;
    private const int SatisfiedFromRating = 7;

    private static readonly DateTime ReservationEpoch = new(2026, 1, 5);

    /// <summary>
    /// Fiksni "danas" za seed. Stanje rezervacije ne smije zavisiti od stvarnog datuma jer
    /// <c>HasData</c> mora biti deterministicki - inace bi svako skafoldovanje migracije
    /// prepisalo svih 60 redova.
    /// </summary>
    internal static readonly DateTime ReservationReferenceDate = new(2026, 8, 27);

    public static void Apply(ModelBuilder modelBuilder)
    {
        SeedCountries(modelBuilder);
        SeedCities(modelBuilder);
        SeedLocations(modelBuilder);
        SeedUsers(modelBuilder);
        SeedAdministrators(modelBuilder);
        SeedPartners(modelBuilder);
        SeedCustomers(modelBuilder);

        var reviews = BuildReviews();
        SeedReferenceData(modelBuilder);
        SeedAccommodations(modelBuilder, AverageRatingPerAccommodation(reviews));
        SeedAccommodationDetails(modelBuilder);
        SeedAccommodationAmenities(modelBuilder);
        SeedAccommodationImages(modelBuilder);
        SeedReservations(modelBuilder);
        modelBuilder.Entity<Review>().HasData(reviews);

        SeedChatsAndMessages(modelBuilder);
    }

    #region Referentni podaci

    private static readonly string[] CountryNames =
    {
        "Bosnia and Herzegovina",
        "Croatia",
        "Serbia",
        "Montenegro",
        "Slovenia",
        "Austria",
    };

    private static readonly (string Name, int Country)[] Cities =
    {
        ("Sarajevo", 1),
        ("Mostar", 1),
        ("Banja Luka", 1),
        ("Zagreb", 2),
        ("Split", 2),
        ("Dubrovnik", 2),
        ("Belgrade", 3),
        ("Budva", 4),
        ("Ljubljana", 5),
        ("Salzburg", 6),
    };

    private static readonly (string Address, double Latitude, double Longitude, int City)[] Locations =
    {
        ("Poljine 14", 43.8901, 18.4103, 1),
        ("Bravadžiluk 24", 43.8594, 18.4318, 1),
        ("Obala Kulina bana 8", 43.8589, 18.4340, 1),
        ("Obala Isa-bega Ishakovića 5", 43.8578, 18.4283, 1),
        ("Zmaja od Bosne 4", 43.8563, 18.4033, 1),
        ("Trebevićka 88", 43.8420, 18.4290, 1),
        ("Maršala Tita 179", 43.3372, 17.8150, 2),
        ("Šetalište Bačvice 10", 43.5030, 16.4530, 5),
        ("Poljana Grgura Ninskog 3", 43.5081, 16.4402, 5),
        ("Masarykov put 9", 42.6450, 18.0850, 6),
        ("Cesta na Rožnik 7", 46.0540, 14.4720, 9),
        ("Hellbrunner Allee 20", 47.7800, 13.0500, 10),
    };

    private static void SeedCountries(ModelBuilder modelBuilder)
    {
        var countries = new List<Country>(CountryCount);
        for (var i = 0; i < CountryNames.Length; i++)
        {
            countries.Add(new Country
            {
                Id = SeedIds.Country(i + 1),
                Name = CountryNames[i],
                IsDeleted = false,
            });
        }

        modelBuilder.Entity<Country>().HasData(countries);
    }

    private static void SeedCities(ModelBuilder modelBuilder)
    {
        var cities = new List<City>(CityCount);
        for (var i = 0; i < Cities.Length; i++)
        {
            cities.Add(new City
            {
                Id = SeedIds.City(i + 1),
                Name = Cities[i].Name,
                CountryId = SeedIds.Country(Cities[i].Country),
                IsDeleted = false,
            });
        }

        modelBuilder.Entity<City>().HasData(cities);
    }

    private static void SeedLocations(ModelBuilder modelBuilder)
    {
        var locations = new List<Location>(Locations.Length);
        for (var i = 0; i < Locations.Length; i++)
        {
            locations.Add(new Location
            {
                Id = SeedIds.Location(i + 1),
                Address = Locations[i].Address,
                Latitude = Locations[i].Latitude,
                Longitude = Locations[i].Longitude,
                CityId = SeedIds.City(Locations[i].City),
                IsDeleted = false,
            });
        }

        modelBuilder.Entity<Location>().HasData(locations);
    }

    #endregion

    #region Korisnici

    private static readonly (string Email, string FirstName, string LastName, string DisplayName,
        Gender Gender, string BirthDate, string Joined, Role Role)[] Users =
    {
        ("admin@ebooking.com", "Amir", "Hodžić", "Amir Hodžić", Gender.Male, "1988-03-14", "2024-01-10", Role.AdministratorRole),
        ("dude@email.com", "Dino", "Kovačević", "Dino Kovačević", Gender.Male, "1990-07-22", "2024-02-05", Role.PartnerRole),
        ("adriatic@email.com", "Ivana", "Marić", "Ivana Marić", Gender.Female, "1986-11-03", "2024-02-18", Role.PartnerRole),
        ("alpine@email.com", "Marko", "Novak", "Marko Novak", Gender.Male, "1983-05-27", "2024-03-02", Role.PartnerRole),
        ("dea@email.com", "Dea", "Selimović", "Dea Selimović", Gender.Female, "1994-04-08", "2024-03-15", Role.CustomerRole),
        ("mobile@ebooking.com", "Amina", "Softić", "Amina Softić", Gender.Female, "1997-09-19", "2024-04-01", Role.CustomerRole),
        ("lejla@email.com", "Lejla", "Bešić", "Lejla Bešić", Gender.Female, "1992-12-11", "2024-04-20", Role.CustomerRole),
        ("emir@email.com", "Emir", "Delić", "Emir Delić", Gender.Male, "1989-06-30", "2024-05-07", Role.CustomerRole),
        ("tarik@email.com", "Tarik", "Zulfikarpašić", "Tarik Zulfikarpašić", Gender.Male, "1995-01-25", "2024-05-23", Role.CustomerRole),
    };

    /// <summary>Redni brojevi korisnika koji su partneri, redom kojim su partneri numerisani.</summary>
    private static readonly int[] PartnerUsers = { 2, 3, 4 };

    /// <summary>Redni brojevi korisnika koji su kupci, redom kojim su kupci numerisani.</summary>
    private static readonly int[] CustomerUsers = { 5, 6, 7, 8, 9 };

    private static void SeedUsers(ModelBuilder modelBuilder)
    {
        var users = new List<User>(Users.Length);
        for (var i = 0; i < Users.Length; i++)
        {
            var row = Users[i];
            users.Add(new User
            {
                Id = SeedIds.User(i + 1),
                Email = row.Email,
                Password = SeedPasswordHashes[i],
                DisplayName = row.DisplayName,
                FirstName = row.FirstName,
                LastName = row.LastName,
                BirthDate = Date(row.BirthDate),
                Gender = row.Gender,
                SocialLink = string.Empty,
                Joined = Date(row.Joined),
                Image = null,
                IsActive = true,
                IsDeleted = false,
                Role = row.Role,
            });
        }

        modelBuilder.Entity<User>().HasData(users);
    }

    private static void SeedAdministrators(ModelBuilder modelBuilder)
    {
        // Administrator, Customer i Accommodation nose sjenovite (shadow) strane ključeve, pa se
        // seeduju kroz anonimni tip — svojstvo UserId ne postoji na samoj klasi.
        modelBuilder.Entity<Administrator>().HasData(new
        {
            Id = SeedIds.Administrator(1),
            UserId = SeedIds.User(1),
            CreatorId = (Guid?)null,
            Joined = Date("2024-01-10"),
            IsDeleted = false,
        });
    }

    private static readonly (long TaxId, string TaxName, long PhoneNumber, int Country)[] Partners =
    {
        (4200123450006, "Dude Apartments d.o.o.", 38761234567, 1),
        (7700998811223, "Adriatic Stays j.d.o.o.", 385912345678, 2),
        (5500221144667, "Alpine Rooms d.o.o.", 38641234567, 5),
    };

    private static void SeedPartners(ModelBuilder modelBuilder)
    {
        var partners = new List<Partner>(PartnerCount);
        for (var i = 0; i < Partners.Length; i++)
        {
            partners.Add(new Partner
            {
                Id = SeedIds.Partner(i + 1),
                UserId = SeedIds.User(PartnerUsers[i]),
                CountryId = SeedIds.Country(Partners[i].Country),
                TaxId = Partners[i].TaxId,
                TaxName = Partners[i].TaxName,
                PhoneNumber = Partners[i].PhoneNumber,
                IsDeleted = false,
            });
        }

        modelBuilder.Entity<Partner>().HasData(partners);
    }

    private static void SeedCustomers(ModelBuilder modelBuilder)
    {
        var customers = new List<object>(CustomerCount);
        for (var i = 0; i < CustomerUsers.Length; i++)
        {
            customers.Add(new
            {
                Id = SeedIds.Customer(i + 1),
                UserId = SeedIds.User(CustomerUsers[i]),
                IsDeleted = false,
            });
        }

        modelBuilder.Entity<Customer>().HasData(customers);
    }

    #endregion

    #region Referentni podaci

    private static readonly (string Name, int Sort)[] AccommodationTypes =
    {
        ("House", 1),
        ("Hotel", 2),
        ("Resort", 3),
        ("Apartment", 4),
        ("Villa", 5),
        ("Hostel", 6),
        ("Cottage", 7),
        ("Penthouse", 8),
    };

    private static readonly (string Code, string Name)[] Amenities =
    {
        ("Bathub", "Bathtub"),
        ("Balcony", "Balcony"),
        ("PrivateBathroom", "Private bathroom"),
        ("AC", "Air conditioning"),
        ("Terrace", "Terrace"),
        ("Kitchen", "Kitchen"),
        ("PrivatePool", "Private pool"),
        ("CoffeeMachine", "Coffee machine"),
        ("View", "View"),
        ("SeaView", "Sea view"),
        ("WashingMachine", "Washing machine"),
        ("SpaTub", "Spa tub"),
        ("SoundProof", "Soundproofing"),
        ("Breakfast", "Breakfast"),
    };

    private static void SeedReferenceData(ModelBuilder modelBuilder)
    {
        var types = new List<AccommodationType>(AccommodationTypes.Length);
        for (var i = 0; i < AccommodationTypes.Length; i++)
        {
            types.Add(new AccommodationType
            {
                Id = SeedIds.AccommodationType(i + 1),
                Name = AccommodationTypes[i].Name,
                SortOrder = AccommodationTypes[i].Sort,
                IsDeleted = false,
            });
        }

        modelBuilder.Entity<AccommodationType>().HasData(types);

        var amenities = new List<Amenity>(Amenities.Length);
        for (var i = 0; i < Amenities.Length; i++)
        {
            amenities.Add(new Amenity
            {
                Id = SeedIds.Amenity(i + 1),
                Code = Amenities[i].Code,
                Name = Amenities[i].Name,
                SortOrder = i + 1,
                IsDeleted = false,
            });
        }

        modelBuilder.Entity<Amenity>().HasData(amenities);
    }

    private static void SeedAccommodationAmenities(ModelBuilder modelBuilder)
    {
        var links = new List<AccommodationDetailsAmenity>();
        for (var i = 0; i < Details.Length; i++)
        {
            var row = Details[i];
            var flags = new[]
            {
                row.Bathub, row.Balcony, row.PrivateBathroom, row.AC, row.Terrace, row.Kitchen,
                row.PrivatePool, row.CoffeeMachine, row.View, row.SeaView, row.WashingMachine,
                row.SpaTub, row.SoundProof, row.Breakfast,
            };

            for (var slot = 0; slot < flags.Length; slot++)
            {
                if (!flags[slot])
                    continue;

                links.Add(new AccommodationDetailsAmenity
                {
                    AccommodationDetailsId = SeedIds.AccommodationDetails(i + 1),
                    AmenityId = SeedIds.Amenity(slot + 1),
                });
            }
        }

        modelBuilder.Entity<AccommodationDetailsAmenity>().HasData(links);
    }

    #endregion

    #region Smještaji

    private static readonly (string Name, TypesOfAccommodation Type, double PricePerNight,
        int Owner, string Description)[] Accommodations =
    {
        ("Villa Poljine", TypesOfAccommodation.Villa, 180,
            1, "Villa with five bedrooms and a view of the Sarajevo valley, a ten-minute drive from the city center."),
        ("Apartment Baščaršija", TypesOfAccommodation.Apartment, 65,
            1, "Apartment in the heart of Baščaršija, next to Sebilj and the main pedestrian zone, with a fully equipped kitchen."),
        ("Hotel Vijećnica", TypesOfAccommodation.Hotel, 120,
            1, "Hotel on the bank of the Miljacka river, across from Vijećnica, with breakfast and free parking for guests."),
        ("Hostel Latinska Ćuprija", TypesOfAccommodation.Hostel, 25,
            1, "Hostel next to the Latin Bridge with a shared kitchen and rooms for two to six guests."),
        ("Penthouse Marijin Dvor", TypesOfAccommodation.Penthouse, 210,
            1, "Attic apartment in Marijin Dvor with a large terrace, a view of Trebević and two parking spaces."),
        ("House on Trebević", TypesOfAccommodation.House, 95,
            1, "House on the slopes of Trebević with a garden and a barbecue, ideal for a family stay away from the city bustle."),
        ("Apartment Stari Most", TypesOfAccommodation.Apartment, 70,
            1, "Apartment in the old part of Mostar, a few steps from the Old Bridge and the Mostar bazaar."),
        ("Villa Riva", TypesOfAccommodation.Villa, 240,
            2, "Villa with a private pool in Bačvice, with direct access to the promenade and the city beach."),
        ("Apartment Diocletian", TypesOfAccommodation.Apartment, 110,
            2, "Apartment inside the walls of Diocletian's Palace, with air conditioning and a view of the old town center."),
        ("Hotel Adriatic", TypesOfAccommodation.Hotel, 320,
            2, "Hotel above the Dubrovnik city walls, with a spa center, restaurant, and a view of the open sea."),
        ("Cottage Rožnik", TypesOfAccommodation.Cottage, 140,
            3, "Cottage in the greenery of Rožnik, a twenty-minute walk from the center of Ljubljana, with a fireplace and terrace."),
        ("Resort Alpenblick", TypesOfAccommodation.Resort, 260,
            3, "Resort near Salzburg with an indoor pool, wellness center, and a view of the Alps."),
    };

    private static void SeedAccommodations(ModelBuilder modelBuilder, IReadOnlyDictionary<int, float> reviewScores)
    {
        var accommodations = new List<object>(AccommodationCount);
        for (var i = 0; i < Accommodations.Length; i++)
        {
            var number = i + 1;
            var row = Accommodations[i];
            accommodations.Add(new
            {
                Id = SeedIds.Accommodation(number),
                Name = row.Name,
                Status = true,
                AccommodationTypeId = SeedIds.AccommodationType((int)row.Type),
                PricePerNight = row.PricePerNight,
                Description = row.Description,
                ReviewScore = reviewScores[number],
                OwnerId = SeedIds.Partner(row.Owner),
                LocationId = SeedIds.Location(number),
                AccommodationDetailsId = SeedIds.AccommodationDetails(number),
                AccommodationImagesId = SeedIds.AccommodationImages(number),
                IsDeleted = false,
            });
        }

        modelBuilder.Entity<Accommodation>().HasData(accommodations);
    }

    /// <summary>
    /// Sadržaji smještaja. Redoslijed odgovara redoslijedu u <see cref="Accommodations"/>.
    /// </summary>
    private static readonly (int Beds, bool Bathub, bool Balcony, bool PrivateBathroom, bool AC,
        bool Terrace, bool Kitchen, bool PrivatePool, bool CoffeeMachine, bool View, bool SeaView,
        bool WashingMachine, bool SpaTub, bool SoundProof, bool Breakfast)[] Details =
    {
        (8, true, true, true, true, true, true, true, true, true, false, true, true, false, false),
        (4, false, true, true, true, false, true, false, true, true, false, true, false, true, false),
        (2, true, true, true, true, false, false, false, true, true, false, false, false, true, true),
        (6, false, false, false, true, false, true, false, false, false, false, true, false, false, false),
        (5, true, true, true, true, true, true, false, true, true, false, true, true, true, false),
        (7, false, true, true, false, true, true, false, false, true, false, true, false, false, false),
        (4, false, true, true, true, false, true, false, true, true, false, false, false, false, false),
        (9, true, true, true, true, true, true, true, true, true, true, true, true, false, false),
        (4, false, true, true, true, false, true, false, true, true, true, true, false, true, false),
        (2, true, true, true, true, true, false, false, true, true, true, false, true, true, true),
        (6, true, false, true, false, true, true, false, true, true, false, true, false, false, false),
        (3, true, true, true, true, true, false, true, true, true, false, false, true, true, true),
    };

    private static void SeedAccommodationDetails(ModelBuilder modelBuilder)
    {
        var details = new List<AccommodationDetails>(AccommodationCount);
        for (var i = 0; i < Details.Length; i++)
        {
            var row = Details[i];
            details.Add(new AccommodationDetails
            {
                Id = SeedIds.AccommodationDetails(i + 1),
                NumberOfBeds = row.Beds,
                IsDeleted = false,
            });
        }

        modelBuilder.Entity<AccommodationDetails>().HasData(details);
    }

    private static void SeedAccommodationImages(ModelBuilder modelBuilder)
    {
        // Kolone Image1..Image5 su obavezne, pa red mora postojati sa praznim nizom bajtova;
        // stvarne fotografije upisuje SeedImageInitializer nakon migracije.
        var images = new List<AccommodationImages>(AccommodationCount);
        for (var number = 1; number <= AccommodationCount; number++)
        {
            images.Add(new AccommodationImages
            {
                AccommodationImagesId = SeedIds.AccommodationImages(number),
                Image1 = Array.Empty<byte>(),
                Image2 = Array.Empty<byte>(),
                Image3 = Array.Empty<byte>(),
                Image4 = Array.Empty<byte>(),
                Image5 = Array.Empty<byte>(),
                IsDeleted = false,
            });
        }

        modelBuilder.Entity<AccommodationImages>().HasData(images);
    }

    #endregion

    #region Rezervacije i recenzije

    private static void SeedReservations(ModelBuilder modelBuilder)
    {
        var reservations = new List<Reservation>(AccommodationCount * ReservationsPerAccommodation);
        for (var accommodation = 1; accommodation <= AccommodationCount; accommodation++)
        {
            for (var index = 0; index < ReservationsPerAccommodation; index++)
            {
                // Termini istog smještaja su razmaknuti 62 dana, a najduži boravak traje 6 noći,
                // pa se seed rezervacije nikad ne preklapaju.
                var start = ReservationEpoch.AddDays(((accommodation - 1) * 3) + (index * 62));
                var nights = 2 + ((accommodation - 1 + index) % 5);
                var customer = ((accommodation - 1 + index) % CustomerCount) + 1;

                var ordinal = ((accommodation - 1) * ReservationsPerAccommodation) + index + 1;
                var end = start.AddDays(nights);
                var status = SeedStatusFor(start, end, accommodation);
                var pricePerNight = (decimal)Accommodations[accommodation - 1].PricePerNight;

                reservations.Add(new Reservation
                {
                    Id = SeedIds.Reservation(ordinal),
                    AccommodationId = SeedIds.Accommodation(accommodation),
                    CustomerId = SeedIds.Customer(customer),
                    StartDate = start,
                    EndDate = end,
                    NumberOfGuests = 1 + ((accommodation - 1 + index) % 4),
                    IsRated = index < ReviewsPerAccommodation,
                    PricePerNight = pricePerNight,
                    TotalPrice = pricePerNight * nights,
                    IsDeleted = false,
                    Status = status,
                    // Stanje je postavljeno deset dana prije dolaska, da datum ne bude prazan.
                    StatusChangedAt = start.AddDays(-10),
                    StatusReason = status == ReservationStatus.Cancelled
                        ? "Guest cancelled the trip."
                        : null,
                });
            }
        }

        modelBuilder.Entity<Reservation>().HasData(reservations);
    }

    private static ReservationStatus SeedStatusFor(DateTime start, DateTime end, int accommodation)
    {
        if (end < ReservationReferenceDate)
            return ReservationStatus.Completed;

        if (start <= ReservationReferenceDate)
            return ReservationStatus.Confirmed;

        return (accommodation % 4) switch
        {
            0 => ReservationStatus.Cancelled,
            1 => ReservationStatus.Pending,
            _ => ReservationStatus.Confirmed
        };
    }

    private static readonly string[] ReviewComments =
    {
        "The accommodation is exactly as described, the host replied right away, and the key handover went smoothly without any waiting.",
        "Clean, quiet, and close to the center. The only downside is the parking, which fills up early in the afternoon.",
        "Excellent value for money, a hearty breakfast, and friendly staff. We will definitely come back.",
        "Everything was tidy, but the heating barely worked the first evening until the host came and adjusted it.",
        "The view from the living room really is just like in the photos, I recommend it for a few days of rest.",
        "The bathroom could use a refresh, but everything else was flawless and we got a later checkout time.",
    };

    private static List<Review> BuildReviews()
    {
        var reviews = new List<Review>(AccommodationCount * ReviewsPerAccommodation);
        for (var accommodation = 1; accommodation <= AccommodationCount; accommodation++)
        {
            for (var index = 0; index < ReviewsPerAccommodation; index++)
            {
                var rating = 1 + ((accommodation - 1 + index) % MaximumRating);
                var customer = ((accommodation - 1 + index) % CustomerCount) + 1;

                reviews.Add(new Review
                {
                    Id = SeedIds.Review(((accommodation - 1) * ReviewsPerAccommodation) + index + 1),
                    AccommodationId = SeedIds.Accommodation(accommodation),
                    CustomerId = SeedIds.Customer(customer),
                    Rating = rating,
                    Satisfaction = rating >= SatisfiedFromRating,
                    WouldRecommend = rating >= SatisfiedFromRating,
                    Comment = (accommodation + index) % 4 == 0
                        ? string.Empty
                        : ReviewComments[(accommodation - 1 + index) % ReviewComments.Length],
                    IsDeleted = false,
                });
            }
        }

        return reviews;
    }

    private static Dictionary<int, float> AverageRatingPerAccommodation(List<Review> reviews)
    {
        var scores = new Dictionary<int, float>(AccommodationCount);
        for (var accommodation = 1; accommodation <= AccommodationCount; accommodation++)
        {
            var id = SeedIds.Accommodation(accommodation);
            var ratings = reviews.Where(r => r.AccommodationId == id).Select(r => r.Rating).ToList();
            scores[accommodation] = (float)Math.Round(ratings.Average(), 1);
        }

        return scores;
    }

    #endregion

    #region Prepiska

    private static void SeedChatsAndMessages(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Chat>().HasData(
            new Chat { Id = SeedIds.Chat(1), User1Id = SeedIds.User(5), User2Id = SeedIds.User(2) },
            new Chat { Id = SeedIds.Chat(2), User1Id = SeedIds.User(7), User2Id = SeedIds.User(3) });

        var conversation = new (int Chat, int Sender, string Content, string Timestamp, bool IsRead)[]
        {
            (1, 5, "Good day, is Apartment Baščaršija available in the first week of June?", "2026-05-12 09:14:00", true),
            (1, 2, "Good day, it is. Check-in is from 2 PM, check-out until 11 AM.", "2026-05-12 09:31:00", true),
            (1, 5, "Great, is parking included in the price?", "2026-05-12 09:35:00", true),
            (1, 2, "Yes, one spot in the building's courtyard. You can confirm the reservation through the app.", "2026-05-12 09:40:00", false),
            (2, 7, "I'm interested in Villa Riva for an extended weekend in July, how many people does it accommodate?", "2026-06-03 18:02:00", true),
            (2, 3, "The villa accommodates up to nine people, has a private pool and access to the promenade.", "2026-06-03 18:20:00", true),
            (2, 7, "Is late check-in possible, we're arriving around 10 PM?", "2026-06-03 18:24:00", true),
            (2, 3, "No problem, I'll wait for you on site.", "2026-06-03 18:29:00", false),
        };

        var messages = new List<Message>(conversation.Length);
        for (var i = 0; i < conversation.Length; i++)
        {
            var row = conversation[i];
            messages.Add(new Message
            {
                Id = SeedIds.Message(i + 1),
                ChatId = SeedIds.Chat(row.Chat),
                SenderId = SeedIds.User(row.Sender),
                Content = row.Content,
                Timestamp = Timestamp(row.Timestamp),
                IsRead = row.IsRead,
            });
        }

        modelBuilder.Entity<Message>().HasData(messages);
    }

    #endregion

    #region Datumi

    /// <summary>
    /// Parsira datum nezavisno od lokalnih postavki mašine. <c>DateTime.Parse</c> bi ovisio o
    /// kulturi pa bi seed mogao dati različite vrijednosti na različitim mašinama.
    /// </summary>
    private static DateTime Date(string value) =>
        DateTime.ParseExact(value, "yyyy-MM-dd", CultureInfo.InvariantCulture);

    private static DateTime Timestamp(string value) =>
        DateTime.ParseExact(value, "yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);

    #endregion
}
