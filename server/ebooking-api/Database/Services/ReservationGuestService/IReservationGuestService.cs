using Models.DTO.ReservationDTO;

namespace Database.Services.ReservationGuestService;

public interface IReservationGuestService
{
    Task AttachGuests(IReadOnlyCollection<ReservationGET> reservations);
}
