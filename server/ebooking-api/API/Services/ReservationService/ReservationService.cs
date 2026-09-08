using System.Linq.Expressions;
using API.Exceptions;
using Models.Constants;
using Models.Domain;
using Repository.Interfaces;
using Services.CurrentUserService;
using Services.RabbitMQService;

namespace Services.ReservationService;

/// <inheritdoc cref="IReservationService"/>
public class ReservationService : IReservationService
{

    public const string TermTakenMessage =
        "The accommodation is already reserved for the selected dates. Please choose different dates.";

    private static readonly IReadOnlyDictionary<ReservationStatus, ReservationStatus[]> Transitions =
        new Dictionary<ReservationStatus, ReservationStatus[]>
        {
            [ReservationStatus.Pending] = new[] { ReservationStatus.Confirmed, ReservationStatus.Rejected, ReservationStatus.Cancelled },
            [ReservationStatus.Confirmed] = new[] { ReservationStatus.Cancelled, ReservationStatus.Completed },
            [ReservationStatus.Cancelled] = Array.Empty<ReservationStatus>(),
            [ReservationStatus.Rejected] = Array.Empty<ReservationStatus>(),
            [ReservationStatus.Completed] = Array.Empty<ReservationStatus>()
        };

    private readonly IGenericRepository<Reservation> _reservationRepository;
    private readonly IGenericRepository<ReservationStatusHistory> _historyRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly IMessageProducer _messageProducer;
    private readonly ILogger<ReservationService> _logger;

    public ReservationService(IGenericRepository<Reservation> reservationRepository,
                              IGenericRepository<ReservationStatusHistory> historyRepository,
                              ICurrentUserService currentUser,
                              IMessageProducer messageProducer,
                              ILogger<ReservationService> logger)
    {
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

    public async Task<Reservation> Create(Reservation reservation, Accommodation accommodation)
    {
        reservation.Status = ReservationStatus.Pending;
        reservation.StatusChangedAt = DateTime.UtcNow;
        reservation.StatusReason = null;

        var nights = (reservation.EndDate.Date - reservation.StartDate.Date).Days;
        reservation.PricePerNight = Math.Round((decimal)accommodation.PricePerNight, 2);
        reservation.TotalPrice = Math.Round(reservation.PricePerNight * nights, 2);

        await _reservationRepository.Add(reservation);
        await WriteHistory(reservation.Id, null, ReservationStatus.Pending, "Reservation created.");

        return reservation;
    }

    public async Task<Reservation> ChangeStatus(Guid reservationId, ReservationStatus target, string? reason)
    {
        var reservation = await _reservationRepository.Get(r => r.Id == reservationId, false,
            r => r.accommodation, r => r.accommodation.Owner, r => r.customer, r => r.customer.User);
        if (reservation == null)
            throw new NotFoundException($"Reservation with identifier {reservationId} does not exist.");

        var actor = await ResolveActor(reservation);
        EnsureTransitionExists(reservation.Status, target);
        EnsureActorMayPerform(reservation, actor, target);

        var trimmedReason = string.IsNullOrWhiteSpace(reason) ? null : reason.Trim();
        if (target == ReservationStatus.Rejected && trimmedReason == null)
            throw new BusinessException("Rejecting a reservation requires a reason that is passed on to the guest.");

        var previous = reservation.Status;
        reservation.Status = target;
        reservation.StatusChangedAt = DateTime.UtcNow;
        reservation.StatusReason = trimmedReason;

        if (!await _reservationRepository.Update(r => r.Id == reservationId, reservation))
            throw new NotFoundException($"Reservation with identifier {reservationId} does not exist.");

        await WriteHistory(reservationId, previous, target, trimmedReason);
        Notify(reservation, previous, target, trimmedReason);

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

    private async Task WriteHistory(Guid reservationId, ReservationStatus? from, ReservationStatus to, string? reason)
    {
        await _historyRepository.Add(new ReservationStatusHistory
        {
            Id = Guid.NewGuid(),
            ReservationId = reservationId,
            FromStatus = from,
            ToStatus = to,
            ChangedByUserId = _currentUser.UserId,
            ChangedByRole = _currentUser.Role,
            ChangedAt = DateTime.UtcNow,
            Reason = reason
        });
    }

    private void Notify(Reservation reservation, ReservationStatus from, ReservationStatus to, string? reason)
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

        var text = $"The reservation for {reservation.accommodation?.Name} " +
                   $"({reservation.StartDate:dd.MM.yyyy.} – {reservation.EndDate:dd.MM.yyyy.}) " +
                   $"changed state from {Name(from)} to {Name(to)}.";

        if (reason != null)
            text += $" Reason: {reason}";

        _messageProducer.SendMessage(new WelcomeMessage
        {
            User1Id = ownerUserId.Value,
            User2Id = guestUserId.Value,
            TimeStamp = DateTime.UtcNow,
            Message = text
        });
    }

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
