using System.Globalization;

namespace Database.Data.Seed;

/// <summary>
/// Determinističke vrijednosti primarnih ključeva za seed podatke.
///
/// <para>
/// <c>HasData</c> zahtijeva da ključevi budu potpuno stabilni: ako se između dva pokretanja
/// promijene, EF bi svaki put generisao novu migraciju koja briše i ponovo ubacuje sve redove.
/// Zbog toga se ovdje ne smije koristiti <see cref="Guid.NewGuid"/>.
/// </para>
///
/// <para>
/// Format ključa je <c>{tip:x8}-0000-0000-0000-{redni_broj:D12}</c> pa se u bazi na prvi pogled
/// vidi kojoj tabeli red pripada (npr. <c>00000008-0000-0000-0000-000000000003</c> je treći smještaj).
/// </para>
/// </summary>
public static class SeedIds
{
    private const int CountryKind = 1;
    private const int CityKind = 2;
    private const int LocationKind = 3;
    private const int UserKind = 4;
    private const int AdministratorKind = 5;
    private const int PartnerKind = 6;
    private const int CustomerKind = 7;
    private const int AccommodationKind = 8;
    private const int AccommodationDetailsKind = 9;
    private const int AccommodationImagesKind = 10;
    private const int ReservationKind = 11;
    private const int ReviewKind = 12;
    private const int ChatKind = 13;
    private const int MessageKind = 14;
    private const int AccommodationTypeKind = 15;
    private const int AmenityKind = 16;

    public static Guid Country(int number) => Build(CountryKind, number);
    public static Guid City(int number) => Build(CityKind, number);
    public static Guid Location(int number) => Build(LocationKind, number);
    public static Guid User(int number) => Build(UserKind, number);
    public static Guid Administrator(int number) => Build(AdministratorKind, number);
    public static Guid Partner(int number) => Build(PartnerKind, number);
    public static Guid Customer(int number) => Build(CustomerKind, number);
    public static Guid Accommodation(int number) => Build(AccommodationKind, number);
    public static Guid AccommodationDetails(int number) => Build(AccommodationDetailsKind, number);
    public static Guid AccommodationImages(int number) => Build(AccommodationImagesKind, number);
    public static Guid Reservation(int number) => Build(ReservationKind, number);
    public static Guid Review(int number) => Build(ReviewKind, number);
    public static Guid Chat(int number) => Build(ChatKind, number);
    public static Guid Message(int number) => Build(MessageKind, number);
    public static Guid AccommodationType(int number) => Build(AccommodationTypeKind, number);
    public static Guid Amenity(int number) => Build(AmenityKind, number);

    private static Guid Build(int kind, int number) =>
        Guid.Parse(string.Create(CultureInfo.InvariantCulture, $"{kind:x8}-0000-0000-0000-{number:D12}"));
}
