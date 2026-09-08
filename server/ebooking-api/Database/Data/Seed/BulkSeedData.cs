using System.Globalization;
using System.Text;
using Models.Domain;

namespace Database.Data.Seed;

public sealed record BulkUser(
    Guid Id,
    string Email,
    string DisplayName,
    string FirstName,
    string LastName,
    DateTime BirthDate,
    short Gender,
    DateTime Joined,
    int Role,
    int AvatarSlot);

public sealed record BulkPartner(Guid Id, Guid UserId, Guid CountryId, long TaxId, string TaxName, long PhoneNumber);

public sealed record BulkCustomer(Guid Id, Guid UserId);

public sealed record BulkLocation(Guid Id, string Address, double Latitude, double Longitude, Guid CityId);

public sealed record BulkAccommodationDetails(Guid Id, int NumberOfBeds);

public sealed record BulkAmenityLink(Guid AccommodationDetailsId, Guid AmenityId);

public sealed record BulkAccommodation(
    Guid Id,
    string Name,
    Guid AccommodationTypeId,
    double PricePerNight,
    string Description,
    decimal ReviewScore,
    Guid OwnerId,
    Guid LocationId,
    Guid AccommodationDetailsId,
    Guid AccommodationImagesId,
    int PhotoSlot);

public sealed record BulkReservation(
    Guid Id,
    Guid AccommodationId,
    Guid CustomerId,
    DateTime StartDate,
    DateTime EndDate,
    int NumberOfGuests,
    decimal PricePerNight,
    decimal TotalPrice,
    int Status,
    DateTime StatusChangedAt,
    string? StatusReason)
{
    public bool IsRated { get; set; }
}

public sealed record BulkReview(
    Guid Id,
    Guid AccommodationId,
    Guid CustomerId,
    int Rating,
    bool Satisfaction,
    bool WouldRecommend,
    string Comment);

public sealed class BulkSeedSet
{
    public List<BulkUser> Users { get; } = new();
    public List<BulkPartner> Partners { get; } = new();
    public List<BulkCustomer> Customers { get; } = new();
    public List<BulkLocation> Locations { get; } = new();
    public List<BulkAccommodationDetails> Details { get; } = new();
    public List<BulkAmenityLink> AmenityLinks { get; } = new();
    public List<BulkAccommodation> Accommodations { get; } = new();
    public List<BulkReservation> Reservations { get; } = new();
    public List<BulkReview> Reviews { get; } = new();
}

public static class BulkSeedData
{
    public const string PasswordHash =
        "pbkdf2-sha256$210000$p+xX7h0tzOl26etFvw54tw==$NnSLcFoPTJ8axX2pvR/UawuSExsveeOmFEyX1GzqBmA=";

    public const int TotalPartners = 100;
    public const int TotalCustomers = 3000;
    public const int TotalAccommodations = 250;
    public const int TotalReservations = 10_000;
    public const int TotalReviews = 8_000;
    public const int TotalCommentedReviews = 1_000;

    private const int CuratedReservations = SeedData.AccommodationCount * SeedData.ReservationsPerAccommodation;
    private const int CuratedReviews = SeedData.AccommodationCount * SeedData.ReviewsPerAccommodation;
    private const int CuratedCommentedReviews = 18;

    private const int GeneratedPartners = TotalPartners - SeedData.PartnerCount;
    private const int GeneratedCustomers = TotalCustomers - SeedData.CustomerCount;
    private const int GeneratedAccommodations = TotalAccommodations - SeedData.AccommodationCount;
    private const int GeneratedReservations = TotalReservations - CuratedReservations;
    private const int GeneratedReviews = TotalReviews - CuratedReviews;
    private const int GeneratedComments = TotalCommentedReviews - CuratedCommentedReviews;

    private const int FirstUserNumber = SeedData.UserCount + 1;
    public const int LastUserNumber = SeedData.UserCount + GeneratedPartners + GeneratedCustomers;

    private const int SlotSpacingInDays = 24;
    private const int MaximumJitterInDays = 17;
    private const int SatisfiedFromRating = 7;
    private const int CustomerStride = 1919;

    private static readonly DateTime ReservationEpoch = new(2024, 3, 20);

    private static readonly string[] MaleFirstNames =
    {
        "Adnan", "Amar", "Emir", "Haris", "Kenan", "Tarik", "Vedad", "Nedim", "Faris", "Damir",
        "Edin", "Mirza", "Almir", "Senad", "Ismar", "Benjamin", "Luka", "Marko", "Ivan", "Ante",
        "Petar", "Nikola", "Stefan", "Miloš", "Vuk", "Matej", "Jure", "Bojan", "Zoran", "Danijel",
    };

    private static readonly string[] FemaleFirstNames =
    {
        "Amina", "Lejla", "Ajla", "Džemila", "Selma", "Merima", "Elma", "Naida", "Emina", "Hana",
        "Ilma", "Sara", "Nejra", "Adna", "Lamija", "Ana", "Ivana", "Marija", "Petra", "Nina",
        "Lucija", "Tea", "Maja", "Katarina", "Jelena", "Milica", "Sanja", "Tamara", "Nika", "Eva",
    };

    private static readonly string[] LastNames =
    {
        "Hodžić", "Kovačević", "Marić", "Novak", "Selimović", "Softić", "Bešić", "Delić",
        "Muminović", "Musić", "Hadžić", "Begić", "Dedić", "Imamović", "Suljić", "Čengić",
        "Alispahić", "Halilović", "Karić", "Horvat", "Kovačić", "Babić", "Jurić", "Vuković",
        "Petrović", "Jovanović", "Nikolić", "Popović", "Ilić", "Marković", "Đurić", "Radić",
        "Pavlović", "Simić", "Tomić", "Blažević", "Knežević", "Grubišić", "Šarac", "Zubović",
    };

    private static readonly string[] PartnerBrands =
    {
        "Panorama", "Horizon", "Linden", "Jasmine", "Viewpoint", "Camellia", "Acacia", "Star",
        "Lavender", "Rose", "Olive", "Pine", "Maple", "Chestnut", "Shore", "Sun",
        "Moonlight", "Dawn", "Anchor", "Seagull", "Dolphin", "Lodge", "Courtyard", "Lily",
        "Blossom", "Quince", "Spruce", "Spring", "Bistro", "Tower", "Vratnik", "Mostina",
        "Sedra", "Adria", "Alpina", "Pannonia", "Neretva", "Vrbas", "Drina", "Una",
    };

    private static readonly string[] CompanySuffixes = { "d.o.o.", "j.d.o.o.", "d.d.", "s.p." };

    private static readonly string[] AccommodationBrands =
    {
        "Panorama", "Horizon", "Linden", "Jasmine", "Viewpoint", "Camellia", "Acacia", "Star",
        "Lavender", "Rose", "Olive", "Pine", "Maple", "Chestnut", "Shore", "Sun",
        "Moonlight", "Dawn", "Anchor", "Seagull", "Dolphin", "Lodge", "Courtyard", "Lily",
    };

    private static readonly string[] TypeWords =
    {
        "House", "Hotel", "Resort", "Apartment", "Villa", "Hostel", "Cottage", "Penthouse",
    };

    private static readonly (int Minimum, int Maximum)[] BedsByType =
    {
        (4, 8), (1, 3), (2, 5), (2, 5), (5, 10), (4, 8), (3, 6), (2, 4),
    };

    private static readonly double[] BasePriceByType = { 90, 130, 250, 70, 200, 25, 110, 210 };

    private static readonly (string Name, double Latitude, double Longitude)[] CityCentres =
    {
        ("Sarajevo", 43.8563, 18.4131),
        ("Mostar", 43.3438, 17.8078),
        ("Banja Luka", 44.7722, 17.1910),
        ("Zagreb", 45.8150, 15.9819),
        ("Split", 43.5081, 16.4402),
        ("Dubrovnik", 42.6507, 18.0944),
        ("Belgrade", 44.7866, 20.4489),
        ("Budva", 42.2911, 18.8400),
        ("Ljubljana", 46.0569, 14.5058),
        ("Salzburg", 47.8095, 13.0550),
    };

    private static readonly int[] CoastalCities = { 5, 6, 8 };

    private static readonly int[] CityPattern =
    {
        1, 2, 4, 5, 1, 6, 7, 8, 1, 9, 10, 3, 1, 5, 2, 6, 1, 7, 4, 9,
    };

    private static readonly string[][] Streets =
    {
        new[] { "Ferhadija", "Titova", "Zmaja od Bosne", "Alipašina", "Koševo", "Bistrik" },
        new[] { "Maršala Tita", "Braće Fejića", "Kralja Petra Krešimira IV", "Bulevar", "Onešćukova", "Kujundžiluk" },
        new[] { "Kralja Petra I", "Gospodska", "Bulevar srpske vojske", "Veselina Masleše", "Jevrejska", "Aleja Svetog Save" },
        new[] { "Ilica", "Vlaška", "Tkalčićeva", "Savska cesta", "Maksimirska", "Frankopanska" },
        new[] { "Marmontova", "Riva", "Bačvice", "Domovinskog rata", "Poljička cesta", "Zrinsko-Frankopanska" },
        new[] { "Stradun", "Od Puča", "Frana Supila", "Iva Vojnovića", "Masarykov put", "Lapadska obala" },
        new[] { "Knez Mihailova", "Bulevar kralja Aleksandra", "Nemanjina", "Kneza Miloša", "Skadarska", "Terazije" },
        new[] { "Slovenska obala", "Mediteranska", "Jadranski put", "Popa Jola Zeca", "Trg Sunca", "Rozino" },
        new[] { "Slovenska cesta", "Trubarjeva cesta", "Celovška cesta", "Dunajska cesta", "Miklošičeva cesta", "Cesta na Rožnik" },
        new[] { "Getreidegasse", "Linzer Gasse", "Hellbrunner Allee", "Rainerstraße", "Schwarzstraße", "Kaigasse" },
    };

    private static readonly string[] DescriptionLeads =
    {
        "The space was recently renovated, with new furniture and linens changed every three days.",
        "All rooms are bright and face the quiet side of the building, away from the noise of the main road.",
        "The city center is a fifteen-minute walk away, and the public transport stop is on the same street.",
        "The host lives nearby and is available for key handover at any time of day.",
        "The kitchen is equipped for preparing full meals, with an oven, microwave, and dishwasher.",
        "Guests have a free parking space in the courtyard and bicycle storage at their disposal.",
        "The internet connection is fiber optic, making the space suitable for remote work during longer stays.",
        "A bakery, pharmacy, and a shop open until midnight are all in the immediate vicinity.",
    };

    private static readonly string[] DescriptionClosings =
    {
        "Check-in is from 2 PM, and check-out is until 11 AM the next day.",
        "Earlier check-in is possible with notice given the day before arrival.",
        "Pets are welcome by prior arrangement with the host.",
        "Smoking is allowed only on the terrace and balcony.",
        "A discount on the total price is granted for stays longer than seven nights.",
        "Linens, towels, and toiletries are included in the price.",
        "An extra bed for a child is provided free of charge.",
        "Breakfast can be arranged for an extra charge at the time of booking.",
    };

    private static readonly string[] PraiseComments =
    {
        "The accommodation is better than in the photos, everything is clean and tidy, and the host is extremely kind.",
        "Everything went flawlessly, from check-in to check-out. The location is excellent for exploring the city on foot.",
        "Spacious, quiet, and warm. The kitchen was equipped with everything we needed, we recommend it without hesitation.",
        "The host welcomed us warmly and gave us useful tips about the city. We will definitely come back.",
        "The view from the terrace is something special, and the bed is the most comfortable we've come across this year.",
        "Excellent value for money. Everything works, nothing feels improvised.",
        "Communication was quick and clear, we picked up the keys without any waiting.",
        "A quiet street, with the center just a ten-minute walk away. Ideal for a stay with children.",
        "The bathroom is new, the water was hot, and the heating was excellent. We have no complaints at all.",
        "We stayed seven nights and wouldn't change a thing. Thanks to the host for everything.",
    };

    private static readonly string[] PositiveComments =
    {
        "Everything was tidy and clean, the only downside is the parking, which fills up early in the afternoon.",
        "The location is excellent, but traffic from the main street can be heard in the morning. Everything else was fine.",
        "The space matches the description. The Wi-Fi tended to drop in the evenings, but nothing serious.",
        "The host was kind, check-in was quick. The kitchen could use a bit more cookware.",
        "Comfortable and quiet, though the stairs are steep so it's not the most practical with large suitcases.",
        "Good accommodation for a short stay. The AC works great, the heating is a bit weaker.",
        "Worth the price. I recommend it, just note that the bed is somewhat firmer.",
        "Full marks for cleanliness, but the shower cabin could use a refresh.",
        "Close to everything we needed. The neighbors could get loud over the weekend.",
        "The stay went smoothly, communication with the host was always quick.",
    };

    private static readonly string[] MixedComments =
    {
        "Average accommodation, neither better nor worse than expected for the price.",
        "The location is good, but the space is smaller than it looks in the photos.",
        "The heating didn't work the first evening until the host came and adjusted it.",
        "It is clean, but the furniture is quite old and a bit wobbly.",
        "Check-in was delayed by almost an hour because the host wasn't on site.",
        "Noise from the street lasts until late at night, hard to sleep without earplugs.",
        "The bathroom is small and poorly ventilated, everything else was fine.",
        "The photos show a better condition than what we found, but it's acceptable for one night.",
    };

    private static readonly string[] NegativeComments =
    {
        "The accommodation was not ready on time, we waited at the door for more than an hour.",
        "Cleanliness was below any standard, the linens had not been changed.",
        "The description does not match the actual condition, half of the listed amenities are missing.",
        "Damp and an unpleasant smell in the bedroom, we couldn't stay the whole night.",
        "The host did not respond to messages during the entire stay.",
        "There was no hot water for two days in a row, and no one came to fix it.",
    };

    private static readonly int[] RatingPattern =
    {
        10, 9, 8, 10, 7, 9, 8, 10, 6, 9, 8, 7, 10, 9, 5, 8, 10, 9, 3, 6,
    };

    private static readonly string[] CancellationReasons =
    {
        "Guest cancelled the trip.",
        "Change of travel dates.",
        "Guest found another accommodation.",
        "Cancelled due to illness in the family.",
    };

    public static BulkSeedSet Build()
    {
        var set = new BulkSeedSet();
        BuildAccounts(set);
        BuildAccommodations(set);
        return set;
    }

    private static void BuildAccounts(BulkSeedSet set)
    {
        var userNumber = FirstUserNumber;

        for (var partner = SeedData.PartnerCount + 1; partner <= TotalPartners; partner++)
        {
            var index = partner - SeedData.PartnerCount - 1;
            var user = MakeUser(userNumber, (int)Role.PartnerRole);
            set.Users.Add(user);

            var brand = PartnerBrands[index % PartnerBrands.Length];
            var suffix = CompanySuffixes[(index / PartnerBrands.Length) % CompanySuffixes.Length];
            var homeCity = CityCentres[index % CityCentres.Length].Name;

            set.Partners.Add(new BulkPartner(
                SeedIds.Partner(partner),
                user.Id,
                SeedIds.Country((index % SeedData.CountryCount) + 1),
                4_200_000_000_000L + (partner * 137L),
                $"{brand} {homeCity} {suffix}",
                38_760_000_000L + (partner * 1234L)));

            userNumber++;
        }

        for (var customer = SeedData.CustomerCount + 1; customer <= TotalCustomers; customer++)
        {
            var user = MakeUser(userNumber, (int)Role.CustomerRole);
            set.Users.Add(user);
            set.Customers.Add(new BulkCustomer(SeedIds.Customer(customer), user.Id));
            userNumber++;
        }
    }

    private static BulkUser MakeUser(int number, int role)
    {
        var isFemale = Mix(number, 11) % 2 == 1;
        var pool = isFemale ? FemaleFirstNames : MaleFirstNames;
        var firstName = pool[Mix(number, 13) % pool.Length];
        var lastName = LastNames[Mix(number, 17) % LastNames.Length];

        var birthYear = 1965 + (Mix(number, 19) % 40);
        var birthDay = Mix(number, 23) % 365;
        var birthDate = new DateTime(birthYear, 1, 1).AddDays(birthDay);

        var joined = new DateTime(2024, 1, 1).AddDays(Mix(number, 29) % 912);

        var email = string.Create(
            CultureInfo.InvariantCulture,
            $"{Ascii(firstName).ToLowerInvariant()}.{Ascii(lastName).ToLowerInvariant()}.{number}@email.com");

        return new BulkUser(
            SeedIds.User(number),
            email,
            Clip($"{firstName} {lastName}", 50),
            Clip(firstName, 15),
            Clip(lastName, 30),
            birthDate,
            (short)(isFemale ? Gender.Female : Gender.Male),
            joined,
            role,
            Mix(number, 31));
    }

    private static void BuildAccommodations(BulkSeedSet set)
    {
        var reservationOrdinal = CuratedReservations;
        var reviewOrdinal = CuratedReviews;
        var commentsPlaced = 0;
        var reviewsPlaced = 0;

        for (var index = 0; index < GeneratedAccommodations; index++)
        {
            var number = SeedData.AccommodationCount + index + 1;
            var partner = SeedData.PartnerCount + 1 + (index % GeneratedPartners);
            var city = CityPattern[index % CityPattern.Length];
            var centre = CityCentres[city - 1];
            var type = (Mix(number, 3) % TypeWords.Length) + 1;

            var beds = BedsByType[type - 1].Minimum
                + (Mix(number, 5) % (BedsByType[type - 1].Maximum - BedsByType[type - 1].Minimum + 1));

            var street = Streets[city - 1][Mix(number, 37) % Streets[city - 1].Length];
            set.Locations.Add(new BulkLocation(
                SeedIds.Location(number),
                $"{street} {(Mix(number, 41) % 180) + 1}",
                Math.Round(centre.Latitude + (((Mix(number, 43) % 801) - 400) / 10000.0), 5),
                Math.Round(centre.Longitude + (((Mix(number, 47) % 801) - 400) / 10000.0), 5),
                SeedIds.City(city)));

            set.Details.Add(new BulkAccommodationDetails(SeedIds.AccommodationDetails(number), beds));

            var amenities = PickAmenities(number, city);
            foreach (var amenity in amenities)
                set.AmenityLinks.Add(new BulkAmenityLink(SeedIds.AccommodationDetails(number), SeedIds.Amenity(amenity)));

            var price = Math.Round(BasePriceByType[type - 1] * (0.75 + ((Mix(number, 53) % 61) / 100.0)));

            var reservationCount = 41 + Spread(index, GeneratedAccommodations, GeneratedReservations - (41 * GeneratedAccommodations));
            var reviewTarget = 33 + Spread(index, GeneratedAccommodations, GeneratedReviews - (33 * GeneratedAccommodations));

            var completed = new List<BulkReservation>(reservationCount);
            var offset = Mix(number, 59) % SlotSpacingInDays;

            for (var slot = 0; slot < reservationCount; slot++)
            {
                reservationOrdinal++;

                var start = ReservationEpoch
                    .AddDays(offset + (SlotSpacingInDays * slot) + (Mix(number, slot + 101) % MaximumJitterInDays));
                var nights = 2 + (Mix(number, slot + 211) % 5);
                var end = start.AddDays(nights);
                var status = StatusFor(start, end, number + slot);
                var customerNumber = ((reservationOrdinal * CustomerStride) % TotalCustomers) + 1;

                var reservation = new BulkReservation(
                    SeedIds.Reservation(reservationOrdinal),
                    SeedIds.Accommodation(number),
                    SeedIds.Customer(customerNumber),
                    start,
                    end,
                    1 + (Mix(number, slot + 307) % Math.Min(8, beds)),
                    (decimal)price,
                    (decimal)price * nights,
                    (int)status,
                    start.AddDays(-10),
                    status == ReservationStatus.Cancelled
                        ? CancellationReasons[Mix(number, slot + 401) % CancellationReasons.Length]
                        : null);

                set.Reservations.Add(reservation);

                if (status == ReservationStatus.Completed)
                    completed.Add(reservation);
            }

            var ratingSum = 0;
            var reviewCount = Math.Min(reviewTarget, completed.Count);

            for (var k = 0; k < reviewCount; k++)
            {
                reviewOrdinal++;
                reviewsPlaced++;

                var source = completed[k];
                source.IsRated = true;

                var rating = RatingPattern[Mix(number, k + 503) % RatingPattern.Length];
                ratingSum += rating;

                var wantsComment = commentsPlaced < GeneratedComments
                    && Spread(reviewsPlaced - 1, GeneratedReviews, GeneratedComments) == 1;

                if (wantsComment)
                    commentsPlaced++;

                set.Reviews.Add(new BulkReview(
                    SeedIds.Review(reviewOrdinal),
                    SeedIds.Accommodation(number),
                    source.CustomerId,
                    rating,
                    rating >= SatisfiedFromRating,
                    rating >= SatisfiedFromRating,
                    wantsComment ? CommentFor(rating, number + k) : string.Empty));
            }

            var score = reviewCount == 0
                ? 0m
                : Math.Round((decimal)ratingSum / reviewCount, 1, MidpointRounding.AwayFromZero);

            set.Accommodations.Add(new BulkAccommodation(
                SeedIds.Accommodation(number),
                Clip($"{TypeWords[type - 1]} {AccommodationBrands[Mix(number, 61) % AccommodationBrands.Length]} {centre.Name}", 50),
                SeedIds.AccommodationType(type),
                price,
                Clip(DescriptionFor(type, centre.Name, beds, amenities.Count, number), 1000),
                score,
                SeedIds.Partner(partner),
                SeedIds.Location(number),
                SeedIds.AccommodationDetails(number),
                SeedIds.AccommodationImages(number),
                Mix(number, 67)));
        }
    }

    private static List<int> PickAmenities(int number, int city)
    {
        var coastal = Array.IndexOf(CoastalCities, city) >= 0;
        var chosen = new List<int>(14);

        for (var slot = 1; slot <= 14; slot++)
        {
            if (slot == 10 && !coastal)
                continue;

            if (slot == 7 && Mix(number, slot + 601) % 100 >= 15)
                continue;

            if (Mix(number, slot + 701) % 10 < 5)
                chosen.Add(slot);
        }

        if (chosen.Count >= 3)
            return chosen;

        foreach (var slot in new[] { (number % 14) + 1, ((number + 5) % 14) + 1, ((number + 9) % 14) + 1 })
        {
            if (slot != 10 && !chosen.Contains(slot))
                chosen.Add(slot);
        }

        chosen.Sort();
        return chosen;
    }

    private static string DescriptionFor(int type, string city, int beds, int amenityCount, int number)
    {
        var lead = DescriptionLeads[Mix(number, 71) % DescriptionLeads.Length];
        var closing = DescriptionClosings[Mix(number, 73) % DescriptionClosings.Length];

        return string.Create(
            CultureInfo.InvariantCulture,
            $"{TypeWords[type - 1]} in the city of {city}, {beds} beds and {amenityCount} amenities available to guests. {lead} {closing}");
    }

    private static string CommentFor(int rating, int seed) => rating switch
    {
        >= 9 => PraiseComments[Mix(seed, 79) % PraiseComments.Length],
        >= SatisfiedFromRating => PositiveComments[Mix(seed, 83) % PositiveComments.Length],
        >= 4 => MixedComments[Mix(seed, 89) % MixedComments.Length],
        _ => NegativeComments[Mix(seed, 97) % NegativeComments.Length],
    };

    private static ReservationStatus StatusFor(DateTime start, DateTime end, int seed)
    {
        if (end < SeedData.ReservationReferenceDate)
            return ReservationStatus.Completed;

        if (start <= SeedData.ReservationReferenceDate)
            return ReservationStatus.Confirmed;

        return (seed % 4) switch
        {
            0 => ReservationStatus.Cancelled,
            1 => ReservationStatus.Pending,
            _ => ReservationStatus.Confirmed,
        };
    }

    private static int Spread(int index, int total, int share) =>
        (int)((((long)index + 1) * share / total) - ((long)index * share / total));

    private static string Clip(string value, int limit) =>
        value.Length <= limit ? value : value[..limit];

    private static string Ascii(string value)
    {
        var builder = new StringBuilder(value.Length);
        foreach (var character in value)
        {
            builder.Append(character switch
            {
                'č' or 'ć' => "c",
                'Č' or 'Ć' => "C",
                'ž' => "z",
                'Ž' => "Z",
                'š' => "s",
                'Š' => "S",
                'đ' => "dj",
                'Đ' => "Dj",
                _ => character.ToString(),
            });
        }

        return builder.ToString();
    }

    private static int Mix(int first, int second)
    {
        unchecked
        {
            var hash = (uint)(first * 73856093) ^ (uint)(second * 19349663);
            hash ^= hash >> 15;
            hash *= 2246822519u;
            hash ^= hash >> 13;
            hash *= 3266489917u;
            hash ^= hash >> 16;
            return (int)(hash & 0x7fffffff);
        }
    }
}
