using System.Linq.Expressions;
using Models.Domain;

namespace Services.LocationService;

public class LocationService : ILocationService
{
    private const double EarthRadiusKm = 6371.0;
    private const double DegreesToRadians = Math.PI / 180;

    public double CalculateDistance(double latitude1, double longitude1, double latitude2, double longitude2)
    {
        var lat1Rad = ToRadians(latitude1);
        var lon1Rad = ToRadians(longitude1);
        var lat2Rad = ToRadians(latitude2);
        var lon2Rad = ToRadians(longitude2);

        var deltaLat = lat2Rad - lat1Rad;
        var deltaLon = lon2Rad - lon1Rad;

        var a = Math.Sin(deltaLat / 2) * Math.Sin(deltaLat / 2) +
                Math.Cos(lat1Rad) * Math.Cos(lat2Rad) *
                Math.Sin(deltaLon / 2) * Math.Sin(deltaLon / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));

        return EarthRadiusKm * c;
    }

    public Expression<Func<Accommodation, bool>> WithinRadius(double latitude, double longitude, double radiusInKilometers)
    {
        var latitudeInRadians = ToRadians(latitude);
        var longitudeInRadians = ToRadians(longitude);

        var sineOfLatitude = Math.Sin(latitudeInRadians);
        var cosineOfLatitude = Math.Cos(latitudeInRadians);

        // Poredi se kosinus ugla umjesto same udaljenosti: kosinus opada na [0, pi], pa je
        // "udaljenost manja od r" isto što i "kosinus veći od cos(r / R)". Time se izbjegava
        // ACOS, koji u SQL Serveru puca kad zaokruživanje da argument neznatno veći od 1.
        var minimumCosine = Math.Cos(radiusInKilometers / EarthRadiusKm);

        return accommodation =>
            accommodation.Location != null &&
            (sineOfLatitude * Math.Sin(accommodation.Location.Latitude * DegreesToRadians)) +
            (cosineOfLatitude * Math.Cos(accommodation.Location.Latitude * DegreesToRadians) *
             Math.Cos((accommodation.Location.Longitude * DegreesToRadians) - longitudeInRadians))
            >= minimumCosine;
    }

    public Expression<Func<Accommodation, double>> ProximityScore(double latitude, double longitude)
    {
        var latitudeInRadians = ToRadians(latitude);
        var longitudeInRadians = ToRadians(longitude);

        var sineOfLatitude = Math.Sin(latitudeInRadians);
        var cosineOfLatitude = Math.Cos(latitudeInRadians);

        return accommodation =>
            accommodation.Location == null ? -1.0 :
            (sineOfLatitude * Math.Sin(accommodation.Location.Latitude * DegreesToRadians)) +
            (cosineOfLatitude * Math.Cos(accommodation.Location.Latitude * DegreesToRadians) *
             Math.Cos((accommodation.Location.Longitude * DegreesToRadians) - longitudeInRadians));
    }

    private static double ToRadians(double degrees) => degrees * DegreesToRadians;
}
