namespace Services.LocationService;

public interface ILocationService
{
    public double CalculateDistance(double latitude1, double longitude1, double latitude2, double longitude2);
}
