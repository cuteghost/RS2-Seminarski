namespace Database.Data.Seed;

public static class SeedSql
{
    public const string BackfillAccommodationCreatedAt = @"
UPDATE a
SET a.CreatedAt = COALESCE(
        DATEADD(day, -14, (SELECT MIN(r.StartDate) FROM Reservations r WHERE r.AccommodationId = a.Id)),
        u.Joined,
        SYSUTCDATETIME())
FROM Accommodations a
LEFT JOIN Partners p ON p.Id = a.OwnerId
LEFT JOIN Users u ON u.Id = p.UserId
WHERE a.CreatedAt IS NULL;";

    public const string PaymentsForCompletedReservations = @"
INSERT INTO Payments (Id, ReservationId, Amount, Currency, Status, Provider, ProviderOrderId, ProviderCaptureId, CreatedAt, CompletedAt, FailureReason, IsDeleted)
SELECT NEWID(), r.Id, r.TotalPrice, 'USD', 2, 'PayPal', NULL, NULL, DATEADD(day, -1, r.StartDate), r.StartDate, NULL, 0
FROM Reservations r
WHERE r.Status = 5 AND r.IsDeleted = 0 AND r.TotalPrice > 0
  AND NOT EXISTS (SELECT 1 FROM Payments p WHERE p.ReservationId = r.Id AND p.IsDeleted = 0);";
}
