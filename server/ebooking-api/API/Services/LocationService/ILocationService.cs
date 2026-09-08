using System.Linq.Expressions;
using Models.Domain;

namespace Services.LocationService;

public interface ILocationService
{
    double CalculateDistance(double latitude1, double longitude1, double latitude2, double longitude2);

    /// <summary>
    /// Uslov „smještaj je unutar <paramref name="radiusInKilometers"/> od zadate tačke", napisan
    /// tako da ga EF prevede u SQL. Zahvaljujući tome se filtriranje i paginacija rade nad bazom,
    /// umjesto da se svi smještaji učitaju i mapiraju pa tek onda odbace.
    /// </summary>
    Expression<Func<Accommodation, bool>> WithinRadius(double latitude, double longitude, double radiusInKilometers);

    Expression<Func<Accommodation, double>> ProximityScore(double latitude, double longitude);
}
