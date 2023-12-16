namespace eBooking.Model.DTO;

public class LocationGet
{
    public long Id { get; set; }
    public string Address { get; set; } = string.Empty;
    public string CityName { get; set; } = string.Empty;
    public string CountryName { get; set; } = string.Empty;

}
