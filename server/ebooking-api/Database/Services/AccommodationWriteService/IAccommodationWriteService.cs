using Models.Domain;

namespace Database.Services.AccommodationWriteService;

public record AccommodationDetailsUpdate(int NumberOfBeds, IReadOnlyCollection<Guid> AmenityIds);

public record AccommodationLocationUpdate(string Address, double Latitude, double Longitude, Guid CityId);

public interface IAccommodationWriteService
{
    Task Update(Accommodation accommodation,
                AccommodationImages? images,
                AccommodationDetailsUpdate? details,
                AccommodationLocationUpdate? location);

    Task SetStatus(Guid accommodationId, bool status);
}
