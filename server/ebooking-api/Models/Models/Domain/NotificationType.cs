namespace Models.Domain;

public enum NotificationType
{
    ReservationCreated = 1,
    ReservationStatusChanged = 2,
    ReservationCancelled = 3,
    PaymentCompleted = 4,
    PasswordChanged = 5,
    AccommodationPromoted = 6
}
