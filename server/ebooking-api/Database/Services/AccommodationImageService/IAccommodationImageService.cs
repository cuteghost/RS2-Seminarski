using Models.Domain;
using Models.DTO.AccommodationDTO;
using Models.DTO.ReservationDTO;

namespace Database.Services.AccommodationImageService;

public interface IAccommodationImageService
{
    Task<Dictionary<Guid, List<int>>> GetImageIndexes(IReadOnlyCollection<Guid> accommodationIds);

    Task<byte[]?> GetImage(Guid accommodationId, int index);

    Task Attach(IReadOnlyCollection<AccommodationGET> accommodations);

    Task AttachThumbnails(IReadOnlyCollection<ReservationGET> reservations);

    Task Replace(Guid accommodationId, AccommodationImages images);
}
