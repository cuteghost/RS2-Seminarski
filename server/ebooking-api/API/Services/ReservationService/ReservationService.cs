using System.Data;
using System.Linq.Expressions;
using API.Exceptions;
using Database;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Models.Constants;
using Models.Domain;
using Repository.Interfaces;
using Services.CurrentUserService;
using Services.RabbitMQService;

namespace Services.ReservationService;

public class ReservationService : IReservationService
{
    public const string TermTakenMessage =
        "The accommodation is already reserved for the selected dates. Please choose different dates.";

    public static readonly TimeOnly EarliestCheckIn = new(12, 0);
    public static readonly TimeOnly LatestCheckIn = new(22, 0);

    private const int SqlDeadlockVictim = 1205;

    private static readonly IReadOnlyDictionary<ReservationStatus, ReservationStatus[]> Transitions =
        new Dictionary<ReservationStatus, ReservationStatus[]>
        {
            [ReservationStatus.Pending] = new[] { ReservationStatus.Confirmed, ReservationStatus.Rejected, ReservationStatus.Cancelled },
            [ReservationStatus.Confirmed] = new[] { ReservationStatus.Cancelled, ReservationStatus.Completed },
            [ReservationStatus.Cancelled] = Array.Empty<ReservationStatus>(),
            [ReservationStatus.Rejected] = Array.Empty<ReservationStatus>(),
            [ReservationStatus.Completed] = Array.Empty<ReservationStatus>()
        };

    private readonly ApplicationDbContext _context;
    private readonly IGenericRepository<Reservation> _reservationRepository;
    private readonly IGenericRepository<ReservationStatusHistory> _historyRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly IMessageProducer _messageProducer;
    private readonly ILogger<ReservationService> _logger;

    public ReservationService(ApplicationDbContext context,
                              IGenericRepository<Reservation> reservationRepository,
                              IGenericRepository<ReservationStatusHistory> historyRepository,
                              ICurrentUserService currentUser,
                              IMessageProducer messageProducer,
                              ILogger<ReservationService> logger)
    {
        _context = context;
        _reservationRepository = reservationRepository;
        _historyRepository = historyRepository;
        _currentUser = currentUser;
        _messageProducer = messageProducer;
        _logger = logger;
    }

    public IReadOnlyCollection<ReservationStatus> AllowedTransitions(ReservationStatus from) =>
        Transitions.TryGetValue(from, out var next) ? next : Array.Empty<ReservationStatus>();

    public Expression<Func<Reservation, bool>> Overlapping(Guid accommodationId, DateTime start, DateTime end)
    {
        var from = start.Date;
        var to = end.Date;

        return reservation =>
            reservation.AccommodationId == accommodationId &&
            reservation.Status != ReservationStatus.Cancelled &&
            reservation.Status != ReservationStatus.Rejected &&
            reservation.StartDate < to &&
            from < reservation.EndDate;
    }

    public Expression<Func<Accommodation, bool>> AvailableBetween(DateTime start, DateTime end)
    {
        var from = start.Date;
        var to = end.Date;

        return accommodation => !accommodation.Reservations.Any(reservation =>
            !reservation.IsDeleted &&
            reservation.Status != ReservationStatus.Cancelled &&
            reservation.Status != ReservationStatus.Rejected &&
            reservation.StartDate < to &&
            from < reservation.EndDate);
    }

    public async Task EnsureTermIsFree(Guid accommodationId, DateTime start, DateTime end)
    {
        if (await _reservationRepository.Any(Overlapping(accommodationId, start, end)))
            throw new BusinessException(TermTakenMessage);
    }

    public async Task<Reservation> Create(Guid customerId, Guid accommodationId, int numberOfGuests,
                                          DateTime startDate, DateTime endDate, TimeOnly? checkInTime)
    {
        if (endDate.Date <= startDate.Date)
            throw new BusinessException("The check-out date must be after the check-in date, at least one day later.");

        if (startDate.Date < DateTime.UtcNow.Date)
            throw new BusinessException("The check-in date cannot be in the past.");

        if (numberOfGuests < 1)
            throw new BusinessException("The number of guests must be a whole number greater than zero.");

        if (checkInTime == null)
            throw new BusinessException("The check-in time is required.");

        if (checkInTime.Value < EarliestCheckIn || checkInTime.Value > LatestCheckIn)
            throw new BusinessException(
                $"The check-in time must be between {EarliestCheckIn:HH\\:mm} and {LatestCheckIn:HH\\:mm}.");

        if (customerId == Guid.Empty || !await _context.Customers.AnyAsync(c => c.Id == customerId && !c.IsDeleted))
            throw new BusinessException("Only a logged-in customer can make a reservation.");

        var accommodation = await _context.Accommodations
            .AsNoTracking()
            .Include(a => a.AccommodationDetails)
            .Include(a => a.Owner)
            .FirstOrDefaultAsync(a => a.Id == accommodationId && !a.IsDeleted);

        if (accommodation == null)
            throw new NotFoundException($"Accommodation with identifier {accommodationId} does not exist.");

        if (accommodation.Owner == null || accommodation.Owner.UserId == null)
            throw new BusinessException("The accommodation has no owner, so it cannot be reserved.");

        if (!accommodation.Status)
            throw new BusinessException("The accommodation is not currently active, so it cannot be reserved.");

        var capacity = accommodation.AccommodationDetails?.NumberOfBeds ?? 0;
        if (capacity < 1)
            throw new BusinessException("The accommodation has no capacity defined, so it cannot be reserved.");

        if (numberOfGuests > capacity)
            throw new BusinessException(
                $"The accommodation can host at most {capacity} guest{(capacity == 1 ? string.Empty : "s")}.");

        var nights = (endDate.Date - startDate.Date).Days;
        var pricePerNight = Math.Round((decimal)accommodation.PricePerNight, 2);

        var reservation = new Reservation
        {
            Id = Guid.NewGuid(),
            AccommodationId = accommodationId,
            CustomerId = customerId,
            NumberOfGuests = numberOfGuests,
            StartDate = startDate.Date,
            EndDate = endDate.Date,
            CheckInTime = checkInTime,
            Status = ReservationStatus.Pending,
            StatusChangedAt = DateTime.UtcNow,
            PricePerNight = pricePerNight,
            TotalPrice = Math.Round(pricePerNight * nights, 2)
        };

        try
        {
            await using var transaction = await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable);

            await EnsureTermIsFree(accommodationId, reservation.StartDate, reservation.EndDate);

            _context.Reservations.Add(reservation);
            _context.ReservationStatusHistory.Add(HistoryRow(reservation.Id, null, ReservationStatus.Pending, "Reservation created."));

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();
        }
        catch (Exception ex) when (IsConcurrentBookingConflict(ex))
        {
            throw new BusinessException(TermTakenMessage);
        }

        NotifyCreated(reservation, accommodation);

        return reservation;
    }

    public async Task<Reservation> ChangeStatus(Guid reservationId, ReservationStatus target, string? reason)
    {
        var reservation = await _context.Reservations
            .Include(r => r.accommodation).ThenInclude(a => a.Owner)
            .Include(r => r.customer).ThenInclude(c => c.User)
            .FirstOrDefaultAsync(r => r.Id == reservationId && !r.IsDeleted);

        if (reservation == null)
            throw new NotFoundException($"Reservation with identifier {reservationId} does not exist.");

        var actor = await ResolveActor(reservation);
        EnsureTransitionExists(reservation.Status, target);
        EnsureActorMayPerform(reservation, actor, target);

        var trimmedReason = string.IsNullOrWhiteSpace(reason) ? null : reason.Trim();
        if (trimmedReason != null && trimmedReason.Length > 500)
            throw new BusinessException("The reason may have at most 500 characters.");

        if (target == ReservationStatus.Rejected && trimmedReason == null)
            throw new BusinessException("Rejecting a reservation requires a reason that is passed on to the guest.");

        if ((target == ReservationStatus.Cancelled || target == ReservationStatus.Rejected) && await IsPaid(reservationId))
            throw new BusinessException(
                "A paid reservation cannot be cancelled because refunds are not supported. Please contact an administrator to resolve it manually.");

        var previous = reservation.Status;

        await using (var transaction = await _context.Database.BeginTransactionAsync())
        {
            reservation.Status = target;
            reservation.StatusChangedAt = DateTime.UtcNow;
            reservation.StatusReason = trimmedReason;

            _context.ReservationStatusHistory.Add(HistoryRow(reservationId, previous, target, trimmedReason));

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();
        }

        NotifyStatusChanged(reservation, previous, target, trimmedReason, actor);

        return reservation;
    }

    public async Task<IReadOnlyList<ReservationStatusHistory>> GetHistory(Guid reservationId)
    {
        var rows = await _historyRepository.GetAll(h => h.ReservationId == reservationId);

        return rows.OrderByDescending(h => h.ChangedAt).ToList();
    }

    private enum Actor
    {
        Administrator,
        Guest,
        Owner
    }

    private Task<bool> IsPaid(Guid reservationId) =>
        _context.Payments.AnyAsync(p => !p.IsDeleted && p.ReservationId == reservationId && p.Status == PaymentStatus.Completed);

    private ReservationStatusHistory HistoryRow(Guid reservationId, ReservationStatus? from, ReservationStatus to, string? reason) =>
        new()
        {
            Id = Guid.NewGuid(),
            ReservationId = reservationId,
            FromStatus = from,
            ToStatus = to,
            ChangedByUserId = _currentUser.UserId,
            ChangedByRole = _currentUser.Role,
            ChangedAt = DateTime.UtcNow,
            Reason = reason
        };

    private static bool IsConcurrentBookingConflict(Exception exception)
    {
        for (var current = exception; current != null; current = current.InnerException)
            if (current is SqlException sql && sql.Number == SqlDeadlockVictim)
                return true;

        return false;
    }

    private async Task<Actor> ResolveActor(Reservation reservation)
    {
        if (_currentUser.Role == Roles.Administrator)
            return Actor.Administrator;

        var customerId = await _currentUser.GetCustomerIdAsync();
        if (customerId != Guid.Empty && reservation.CustomerId == customerId)
            return Actor.Guest;

        var partnerId = await _currentUser.GetPartnerIdAsync();
        if (partnerId != Guid.Empty && reservation.accommodation != null && reservation.accommodation.OwnerId == partnerId)
            return Actor.Owner;

        throw new BusinessException("This reservation does not belong to you.");
    }

    private void EnsureTransitionExists(ReservationStatus from, ReservationStatus target)
    {
        if (from == target)
            throw new BusinessException($"The reservation is already in the {Name(from)} state.");

        var allowed = AllowedTransitions(from);
        if (allowed.Count == 0)
            throw new BusinessException(
                $"The reservation is in the final state {Name(from)} and can no longer be changed.");

        if (!allowed.Contains(target))
            throw new BusinessException(
                $"Cannot move from state {Name(from)} to {Name(target)}. Allowed: {string.Join(", ", allowed.Select(Name))}.");
    }

    private void EnsureActorMayPerform(Reservation reservation, Actor actor, ReservationStatus target)
    {
        if (actor == Actor.Administrator)
        {
            EnsureTimingIsSane(reservation, target, isAdministrator: true);
            return;
        }

        switch (target)
        {
            case ReservationStatus.Confirmed:
            case ReservationStatus.Rejected:
                if (actor != Actor.Owner)
                    throw new BusinessException("A reservation is accepted or rejected by the accommodation owner.");
                break;

            case ReservationStatus.Cancelled:
                if (actor != Actor.Guest)
                    throw new BusinessException(
                        "A reservation is cancelled by the guest or an administrator. The accommodation owner may reject it while it is pending.");
                break;

            case ReservationStatus.Completed:
                if (actor != Actor.Owner)
                    throw new BusinessException("A stay is completed by the accommodation owner.");
                break;
        }

        EnsureTimingIsSane(reservation, target, isAdministrator: false);
    }

    private static void EnsureTimingIsSane(Reservation reservation, ReservationStatus target, bool isAdministrator)
    {
        var today = DateTime.UtcNow.Date;

        if (target == ReservationStatus.Completed && reservation.EndDate.Date > today)
            throw new BusinessException(
                $"A stay can only be completed after the check-out date ({reservation.EndDate:dd.MM.yyyy.}).");

        if (target == ReservationStatus.Cancelled && !isAdministrator && reservation.StartDate.Date <= today)
            throw new BusinessException(
                "The stay has already started, so you cannot cancel it yourself. Please contact an administrator.");
    }

    private void NotifyCreated(Reservation reservation, Accommodation accommodation)
    {
        var ownerUserId = accommodation.Owner?.UserId;
        var period = Period(reservation);

        _messageProducer.Publish(new NotificationEvent
        {
            UserId = _currentUser.UserId,
            Type = NotificationType.ReservationCreated,
            Title = "Reservation sent",
            Body = $"Your reservation for {accommodation.Name} ({period}) was sent and is waiting for the owner's confirmation.",
            RelatedEntityId = reservation.Id,
            CreatedAt = DateTime.UtcNow
        });

        if (ownerUserId.HasValue)
        {
            _messageProducer.Publish(new NotificationEvent
            {
                UserId = ownerUserId.Value,
                Type = NotificationType.ReservationCreated,
                Title = "New reservation request",
                Body = $"A guest requested {accommodation.Name} for {period} ({reservation.NumberOfGuests} guests, check-in at {reservation.CheckInTime:HH\\:mm}).",
                RelatedEntityId = reservation.Id,
                CreatedAt = DateTime.UtcNow
            });

            _messageProducer.SendMessage(new WelcomeMessage
            {
                User1Id = ownerUserId.Value,
                User2Id = _currentUser.UserId,
                TimeStamp = DateTime.UtcNow,
                Message = $"Dear Guest,\r\n\r\nThank you for choosing {accommodation.Name}. " +
                          $"Your request for {period} has been received and we will confirm it shortly. " +
                          "If you have any special requests, feel free to write to us here.\r\n\r\nWarm regards"
            });
        }
    }

    private void NotifyStatusChanged(Reservation reservation, ReservationStatus from, ReservationStatus to, string? reason, Actor actor)
    {
        var ownerUserId = reservation.accommodation?.Owner?.UserId;
        var guestUserId = reservation.customer?.User?.Id;

        if (ownerUserId == null || guestUserId == null)
        {
            _logger.LogWarning(
                "Obavještenje o promjeni stanja rezervacije {ReservationId} nije poslano jer nedostaje korisnik vlasnika ili gosta.",
                reservation.Id);
            return;
        }

        var type = to == ReservationStatus.Cancelled ? NotificationType.ReservationCancelled : NotificationType.ReservationStatusChanged;
        var title = $"Reservation {Name(to)}";
        var body = $"The reservation for {reservation.accommodation?.Name} ({Period(reservation)}) changed from {Name(from)} to {Name(to)}.";
        if (reason != null)
            body += $" Reason: {reason}";

        var recipients = new List<Guid>();
        if (actor != Actor.Guest)
            recipients.Add(guestUserId.Value);
        if (actor != Actor.Owner)
            recipients.Add(ownerUserId.Value);

        foreach (var recipient in recipients)
        {
            _messageProducer.Publish(new NotificationEvent
            {
                UserId = recipient,
                Type = type,
                Title = title,
                Body = body,
                RelatedEntityId = reservation.Id,
                CreatedAt = DateTime.UtcNow
            });
        }

        _messageProducer.SendMessage(new WelcomeMessage
        {
            User1Id = ownerUserId.Value,
            User2Id = guestUserId.Value,
            TimeStamp = DateTime.UtcNow,
            Message = body
        });
    }

    private static string Period(Reservation reservation) =>
        $"{reservation.StartDate:dd.MM.yyyy.} – {reservation.EndDate:dd.MM.yyyy.}";

    private static string Name(ReservationStatus status) => status switch
    {
        ReservationStatus.Pending => "pending",
        ReservationStatus.Confirmed => "confirmed",
        ReservationStatus.Cancelled => "cancelled",
        ReservationStatus.Rejected => "rejected",
        ReservationStatus.Completed => "completed",
        _ => status.ToString()
    };
}
