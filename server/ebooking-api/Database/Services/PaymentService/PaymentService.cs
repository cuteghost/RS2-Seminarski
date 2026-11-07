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

    public async Task<PaymentSummary> GetSummary(Guid reservationId, Guid customerId)
    {
        var reservation = await LoadReservation(reservationId);
        EnsurePayable(reservation, customerId);

        var latest = await GetForReservation(reservationId);
        var isPaid = latest?.Status == PaymentStatus.Completed;

        return new PaymentSummary
        {
            ReservationId = reservationId,
            PaymentId = latest?.Id,
            AccommodationName = reservation.accommodation!.Name,
            PricePerNight = (double)PricePerNightFor(reservation),
            Nights = (reservation.EndDate.Date - reservation.StartDate.Date).Days,
            Amount = isPaid ? latest!.Amount : AmountFor(reservation),
            Currency = latest?.Currency ?? "USD",
            IsPaid = isPaid
        };
    }

    public async Task<Payment> StartPayment(Guid reservationId, Guid customerId)
    {
        var reservation = await LoadReservation(reservationId);
        EnsurePayable(reservation, customerId);

        var open = await _context.Payments
            .Where(p => !p.IsDeleted && p.ReservationId == reservationId
                        && (p.Status == PaymentStatus.Created || p.Status == PaymentStatus.Completed))
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

        if (open.Any(p => p.Status == PaymentStatus.Completed))
            throw new BusinessException("The reservation has already been paid.");

        var amount = AmountFor(reservation);

        await using var transaction = await _context.Database.BeginTransactionAsync();

        var reusable = open.FirstOrDefault(p => p.ProviderOrderId == null);
        foreach (var abandoned in open.Where(p => p != reusable))
        {
            abandoned.Status = PaymentStatus.Cancelled;
            abandoned.FailureReason = "Superseded by a new payment attempt before it was captured.";
        }

        if (reusable != null)
        {
            reusable.Amount = amount;
            await _context.SaveChangesAsync();
            await transaction.CommitAsync();
            return reusable;
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
        await transaction.CommitAsync();

        return payment;
    }

    public async Task<Payment> AttachProviderOrder(Guid paymentId, string providerOrderId)
    {
        var payment = await _context.Payments.FirstOrDefaultAsync(p => !p.IsDeleted && p.Id == paymentId);
        if (payment == null)
            throw new NotFoundException($"Payment with identifier {paymentId} does not exist.");

        if (payment.Status != PaymentStatus.Created)
            throw new BusinessException("This payment attempt is no longer open.");

        payment.ProviderOrderId = providerOrderId;
        await _context.SaveChangesAsync();

        return payment;
    }

    public async Task<Payment> GetOwnedByProviderOrder(string providerOrderId, Guid reservationId, Guid customerId)
    {
        var payment = await _context.Payments
            .Include(p => p.Reservation)
                .ThenInclude(r => r!.accommodation)
                    .ThenInclude(a => a.Owner)
            .FirstOrDefaultAsync(p => !p.IsDeleted && p.ProviderOrderId == providerOrderId);

        if (payment == null || payment.Reservation == null)
            throw new NotFoundException($"Payment for order {providerOrderId} does not exist.");

        if (payment.ReservationId != reservationId)
            throw new BusinessException("The payment ticket does not belong to this payment.");

        if (payment.Reservation.CustomerId != customerId)
            throw new BusinessException("This payment does not belong to you.");

        return payment;
    }

    public async Task<Payment> CompletePayment(Guid paymentId, string providerCaptureId, decimal capturedAmount, string currency)
    {
        var payment = await FindById(paymentId);

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

    public async Task<Payment> FailPayment(Guid paymentId, string reason)
    {
        var payment = await FindById(paymentId);

        if (payment.Status == PaymentStatus.Completed)
            return payment;

        payment.Status = PaymentStatus.Failed;
        payment.FailureReason = reason.Length > 500 ? reason[..500] : reason;
        await _context.SaveChangesAsync();

        return payment;
    }

    public async Task<Payment?> GetForReservation(Guid reservationId)
    {
        var payments = await _context.Payments
            .AsNoTracking()
            .Where(p => !p.IsDeleted && p.ReservationId == reservationId)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

        return payments.FirstOrDefault(p => p.Status == PaymentStatus.Completed) ?? payments.FirstOrDefault();
    }

    public async Task<bool> IsPaid(Guid reservationId)
    {
        return await _context.Payments
            .AnyAsync(p => !p.IsDeleted && p.ReservationId == reservationId && p.Status == PaymentStatus.Completed);
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

    private static void EnsurePayable(Reservation reservation, Guid customerId)
    {
        if (reservation.CustomerId != customerId)
            throw new BusinessException("This reservation does not belong to you.");

        if (reservation.Status != ReservationStatus.Confirmed)
            throw new BusinessException("Only a reservation confirmed by the accommodation owner can be paid.");
    }

    private async Task<Payment> FindById(Guid paymentId)
    {
        var payment = await _context.Payments
            .FirstOrDefaultAsync(p => !p.IsDeleted && p.Id == paymentId);

        if (payment == null)
            throw new NotFoundException($"Payment with identifier {paymentId} does not exist.");

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
