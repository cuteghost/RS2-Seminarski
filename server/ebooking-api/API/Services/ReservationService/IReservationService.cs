using System.Linq.Expressions;
using Models.Domain;

namespace Services.ReservationService;

public interface IReservationService
{
    IReadOnlyCollection<ReservationStatus> AllowedTransitions(ReservationStatus from);

    Expression<Func<Reservation, bool>> Overlapping(Guid accommodationId, DateTime start, DateTime end);

    Expression<Func<Accommodation, bool>> AvailableBetween(DateTime start, DateTime end);

    Task EnsureTermIsFree(Guid accommodationId, DateTime start, DateTime end);

    Task<Reservation> Create(Guid customerId, Guid accommodationId, int numberOfGuests,
                             DateTime startDate, DateTime endDate, TimeOnly? checkInTime);

    Task<Reservation> ChangeStatus(Guid reservationId, ReservationStatus target, string? reason);

    Task<IReadOnlyList<ReservationStatusHistory>> GetHistory(Guid reservationId);
}
