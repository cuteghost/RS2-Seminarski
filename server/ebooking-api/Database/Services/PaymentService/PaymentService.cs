using API.Exceptions;
using Microsoft.EntityFrameworkCore;
using Models.Domain;

namespace Database.Services.PaymentService;

public class PaymentService : IPaymentService
{
    private const decimal AmountTolerance = 0.01m;

    private readonly ApplicationDbContext _context;

    public PaymentService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<decimal> CalculateAmount(Guid reservationId)
    {
        var reservation = await LoadReservation(reservationId);

        return AmountFor(reservation);
    }

    public async Task<Payment> StartPayment(Guid reservationId, Guid customerId)
    {
        var reservation = await LoadReservation(reservationId);

        if (reservation.CustomerId != customerId)
            throw new BusinessException("This reservation does not belong to you.");

        if (reservation.Status == ReservationStatus.Cancelled || reservation.Status == ReservationStatus.Rejected)
            throw new BusinessException("A cancelled or rejected reservation cannot be paid.");

        var existing = await _context.Payments
            .Where(p => !p.IsDeleted && p.ReservationId == reservationId)
            .OrderByDescending(p => p.CreatedAt)
            .FirstOrDefaultAsync();

        if (existing != null && existing.Status == PaymentStatus.Completed)
            throw new BusinessException("The reservation has already been paid.");

        var amount = AmountFor(reservation);

        if (existing != null && existing.Status == PaymentStatus.Created)
        {
            existing.Amount = amount;
            existing.ProviderOrderId = null;
            await _context.SaveChangesAsync();
            return existing;
        }

        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            ReservationId = reservationId,
            Amount = amount,
            Currency = "USD",
            Status = PaymentStatus.Created,
            Provider = "PayPal",
            CreatedAt = DateTime.UtcNow
        };

        _context.Payments.Add(payment);
        await _context.SaveChangesAsync();

        return payment;
    }

    public async Task<Payment> AttachProviderOrder(Guid paymentId, string providerOrderId)
    {
        var payment = await _context.Payments.FirstOrDefaultAsync(p => !p.IsDeleted && p.Id == paymentId);
        if (payment == null)
            throw new NotFoundException($"Payment with identifier {paymentId} does not exist.");

        if (payment.Status == PaymentStatus.Completed)
            throw new BusinessException("The reservation has already been paid.");

        payment.ProviderOrderId = providerOrderId;
        await _context.SaveChangesAsync();

        return payment;
    }

    public async Task<Payment> CompletePayment(string providerOrderId, string providerCaptureId, decimal capturedAmount, string currency)
    {
        var payment = await FindByOrder(providerOrderId);

        if (payment.Status == PaymentStatus.Completed)
            return payment;

        if (Math.Abs(payment.Amount - capturedAmount) > AmountTolerance)
        {
            payment.Status = PaymentStatus.Failed;
            payment.FailureReason = $"Charged amount {capturedAmount} {currency} does not match the expected {payment.Amount} {payment.Currency}.";
            await _context.SaveChangesAsync();

            throw new BusinessException(payment.FailureReason);
        }

        if (!string.Equals(payment.Currency, currency, StringComparison.OrdinalIgnoreCase))
        {
            payment.Status = PaymentStatus.Failed;
            payment.FailureReason = $"Charge currency {currency} does not match the expected {payment.Currency}.";
            await _context.SaveChangesAsync();

            throw new BusinessException(payment.FailureReason);
        }

        payment.Status = PaymentStatus.Completed;
        payment.ProviderCaptureId = providerCaptureId;
        payment.CompletedAt = DateTime.UtcNow;
        payment.FailureReason = null;
        await _context.SaveChangesAsync();

        return payment;
    }

    public async Task<Payment> FailPayment(string providerOrderId, string reason)
    {
        var payment = await FindByOrder(providerOrderId);

        if (payment.Status == PaymentStatus.Completed)
            return payment;

        payment.Status = PaymentStatus.Failed;
        payment.FailureReason = reason.Length > 500 ? reason[..500] : reason;
        await _context.SaveChangesAsync();

        return payment;
    }

    public async Task<Payment?> GetForReservation(Guid reservationId)
    {
        return await _context.Payments
            .AsNoTracking()
            .Where(p => !p.IsDeleted && p.ReservationId == reservationId)
            .OrderByDescending(p => p.CreatedAt)
            .FirstOrDefaultAsync();
    }

    public async Task<Payment?> GetByProviderOrder(string providerOrderId)
    {
        return await _context.Payments
            .AsNoTracking()
            .FirstOrDefaultAsync(p => !p.IsDeleted && p.ProviderOrderId == providerOrderId);
    }

    public async Task<HashSet<Guid>> GetPaidReservationIds(IReadOnlyCollection<Guid> reservationIds)
    {
        if (reservationIds.Count == 0)
            return new HashSet<Guid>();

        var paid = await _context.Payments
            .AsNoTracking()
            .Where(p => !p.IsDeleted
                        && p.Status == PaymentStatus.Completed
                        && reservationIds.Contains(p.ReservationId))
            .Select(p => p.ReservationId)
            .Distinct()
            .ToListAsync();

        return paid.ToHashSet();
    }

    public async Task<Guid> GetCustomerIdForUser(Guid userId)
    {
        var customer = await _context.Customers
            .AsNoTracking()
            .FirstOrDefaultAsync(c => !c.IsDeleted && EF.Property<Guid>(c, "UserId") == userId);

        return customer?.Id ?? Guid.Empty;
    }

    public async Task<PaymentSummary> GetSummary(Guid reservationId, Guid customerId)
    {
        var reservation = await LoadReservation(reservationId);

        if (reservation.CustomerId != customerId)
            throw new BusinessException("This reservation does not belong to you.");

        var payment = await StartPayment(reservationId, customerId);

        return new PaymentSummary
        {
            ReservationId = reservationId,
            PaymentId = payment.Id,
            AccommodationName = reservation.accommodation!.Name,
            PricePerNight = (double)PricePerNightFor(reservation),
            Nights = (reservation.EndDate.Date - reservation.StartDate.Date).Days,
            Amount = payment.Amount,
            Currency = payment.Currency,
            IsPaid = payment.Status == PaymentStatus.Completed
        };
    }

    private async Task<Payment> FindByOrder(string providerOrderId)
    {
        var payment = await _context.Payments
            .FirstOrDefaultAsync(p => !p.IsDeleted && p.ProviderOrderId == providerOrderId);

        if (payment == null)
            throw new NotFoundException($"Payment for order {providerOrderId} does not exist.");

        return payment;
    }

    private async Task<Reservation> LoadReservation(Guid reservationId)
    {
        var reservation = await _context.Reservations
            .AsNoTracking()
            .Include(r => r.accommodation)
            .FirstOrDefaultAsync(r => !r.IsDeleted && r.Id == reservationId);

        if (reservation == null)
            throw new NotFoundException($"Reservation with identifier {reservationId} does not exist.");

        if (reservation.accommodation == null)
            throw new BusinessException("Reservation is not linked to an accommodation, so the amount cannot be calculated.");

        return reservation;
    }

    private static decimal PricePerNightFor(Reservation reservation)
    {
        return reservation.PricePerNight > 0
            ? reservation.PricePerNight
            : Math.Round((decimal)reservation.accommodation!.PricePerNight, 2);
    }

    private static decimal AmountFor(Reservation reservation)
    {
        if (reservation.TotalPrice > 0)
            return reservation.TotalPrice;

        var nights = (reservation.EndDate.Date - reservation.StartDate.Date).Days;
        if (nights < 1)
            throw new BusinessException("Reservation must last at least one night for the amount to be calculated.");

        return Math.Round(PricePerNightFor(reservation) * nights, 2);
    }
}
