using System.Linq.Expressions;

namespace Models.Domain;

public static class ReservationPolicy
{
    public static Expression<Func<Reservation, bool>> HoldsTerm(Guid accommodationId, DateTime now)
    {
        var today = now.Date;

        return reservation =>
            reservation.AccommodationId == accommodationId &&
            (reservation.Status == ReservationStatus.Pending || reservation.Status == ReservationStatus.Confirmed) &&
            reservation.EndDate >= today;
    }

    public static Expression<Func<Reservation, bool>> BlocksCustomerClosure(Guid customerId, DateTime now)
    {
        var today = now.Date;

        return reservation =>
            reservation.CustomerId == customerId &&
            (reservation.Status == ReservationStatus.Pending || reservation.Status == ReservationStatus.Confirmed) &&
            reservation.EndDate >= today;
    }

    public static Expression<Func<Reservation, bool>> BlocksPartnerClosure(Guid partnerId, DateTime now)
    {
        var today = now.Date;

        return reservation =>
            reservation.accommodation.OwnerId == partnerId &&
            !reservation.accommodation.IsDeleted &&
            (reservation.Status == ReservationStatus.Pending || reservation.Status == ReservationStatus.Confirmed) &&
            reservation.EndDate >= today;
    }
}
