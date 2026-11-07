using Models.Domain;

namespace Database.Services.AccommodationWriteService;

public record AccommodationInput(string Name, string Description, double PricePerNight, Guid AccommodationTypeId);

public record AccommodationDetailsUpdate(int NumberOfBeds, IReadOnlyCollection<Guid> AmenityIds);

public record AccommodationLocationUpdate(string Address, double Latitude, double Longitude, Guid CityId);

public interface IAccommodationWriteService
{
    Task<Guid> Create(Guid ownerId,
                      AccommodationInput input,
                      AccommodationDetailsUpdate? details,
                      AccommodationLocationUpdate? location,
                      AccommodationImages? images);

    Task Update(Guid accommodationId,
                AccommodationInput input,
                AccommodationImages? images,
                AccommodationDetailsUpdate? details,
                AccommodationLocationUpdate? location);

    Task SetStatus(Guid accommodationId, bool status);

    Task SetPromoted(Guid accommodationId, bool promoted);
}
