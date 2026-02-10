using System.Data;
using API.Exceptions;
using AutoMapper;
using Database.Services.AccommodationImageService;
using Database.Services.PaymentService;
using Database.Services.ReservationGuestService;
using Database.Services.ReservationHistoryService;
using Database;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Models.Constants;
using Models.Domain;
using Models.DTO.ReservationDTO;
using Repository.Interfaces;
using Services.CurrentUserService;
using Services.RabbitMQService;
using Services.ReservationService;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class ReservationController : Controller
{
    private readonly IGenericRepository<Reservation> _reservationRepo;
    private readonly IGenericRepository<Customer> _customerRepo;
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IGenericRepository<Review> _reviewRepo;
    private readonly ICurrentUserService _currentUser;
    private readonly IReservationService _reservationService;
    private readonly IPaymentService _paymentService;
    private readonly IAccommodationImageService _imageService;
    private readonly IReservationGuestService _guestService;
    private readonly IReservationHistoryActorService _historyActorService;
    private readonly IMapper _mapper;
    private readonly IMessageProducer _messageProducer;
    private readonly ApplicationDbContext _context;

    private const int SqlDeadlockVictim = 1205;

    public ReservationController(IGenericRepository<Reservation> reservationRepo,
                                 ICurrentUserService currentUser,
                                 IReservationService reservationService,
                                 IPaymentService paymentService,
                                 IAccommodationImageService imageService,
                                 IReservationGuestService guestService,
                                 IReservationHistoryActorService historyActorService,
                                 IMapper mapper,
                                 IGenericRepository<Review> reviewRepo,
                                 IGenericRepository<Customer> customerRepo,
                                 IGenericRepository<Accommodation> accommodationRepo,
                                 IMessageProducer messageProducer,
                                 ApplicationDbContext context)
    {
        _reservationRepo = reservationRepo;
        _currentUser = currentUser;
        _reservationService = reservationService;
        _paymentService = paymentService;
        _imageService = imageService;
        _guestService = guestService;
        _historyActorService = historyActorService;
        _mapper = mapper;
        _reviewRepo = reviewRepo;
        _customerRepo = customerRepo;
        _accommodationRepo = accommodationRepo;
        _messageProducer = messageProducer;
        _context = context;
    }

    [HttpPost]
    [Route("Create")]
    public async Task<IActionResult> Create([FromBody] ReservationPOST reservationDto)
    {
        if (reservationDto.EndDate.Date <= reservationDto.StartDate.Date)
            throw new BusinessException("The check-out date must be after the check-in date, at least one day later.");

        if (reservationDto.StartDate.Date < DateTime.UtcNow.Date)
            throw new BusinessException("The check-in date cannot be in the past.");

        if (reservationDto.NumberOfGuests < 1)
            throw new BusinessException("The number of guests must be a whole number greater than zero.");

        var customerId = await _currentUser.GetCustomerIdAsync();
        var userId = _currentUser.UserId;

        var customer = await _customerRepo.Get(c => c.Id == customerId, false);
        if (customer == null)
            throw new BusinessException("Only a logged-in customer can make a reservation.");

        var accommodation = await _accommodationRepo.Get(c => c.Id == reservationDto.AccommodationId, false, c => c.Owner, c => c.Owner.User);
        if (accommodation == null)
            throw new NotFoundException($"Accommodation with identifier {reservationDto.AccommodationId} does not exist.");

        if (accommodation.Owner == null)
            throw new BusinessException("The accommodation has no owner, so it cannot be reserved.");

        if (!accommodation.Status)
            throw new BusinessException("The accommodation is not currently active, so it cannot be reserved.");

        var ownerId = accommodation.Owner.UserId;

        Reservation reservation;
        await using (var transaction = await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable))
        {
            try
            {
                await _reservationService.EnsureTermIsFree(reservationDto.AccommodationId, reservationDto.StartDate, reservationDto.EndDate);

                reservation = _mapper.Map<Reservation>(reservationDto);
                reservation.Id = Guid.NewGuid();
                reservation.CustomerId = customerId;

                await _reservationService.Create(reservation, accommodation);

                await transaction.CommitAsync();
            }
            catch (Exception ex) when (IsConcurrentBookingConflict(ex))
            {
                throw new BusinessException(Services.ReservationService.ReservationService.TermTakenMessage);
            }
        }

        var message = new WelcomeMessage
        {
            User1Id = ownerId ?? Guid.Empty,
            User2Id = userId,
            Message = $"Dear Guest," +
                      $"\r\n\r\n" +
                      $"We are delighted to welcome you to {accommodation.Name}! " +
                      $"Thank you for choosing to stay with us. Our team is committed to ensuring that your experience is both comfortable and memorable." +
                      $"\r\n\r\nDuring your stay, we invite you to take full advantage of our amenities. " +
                      $"If there is anything you need or if you have any special requests, please do not hesitate to reach out to our friendly staff, available 24/7 to assist you.\r\n\r\n" +
                      $"To help you make the most of your visit check out suggestions app is offering.\r\n\r\n" +
                      $"We hope you have a wonderful stay and enjoy everything our city has to offer." +
                      $"\r\n\r\nWarm regards,\r\n\r\n{accommodation.Owner.User.DisplayName}\r\n\r\nCheck-In Date{reservation.StartDate} <-> Check-out Date{reservation.EndDate.Date}"
        };

        _messageProducer.SendMessage(message);

        var created = await _reservationRepo.Get(r => r.Id == reservation.Id, false,
            r => r.accommodation, r => r.accommodation.AccommodationType, r => r.accommodation.AccommodationDetails, r => r.accommodation.Location, r => r.accommodation.Location.City, r => r.accommodation.Location.City.Country);
        var mapped = _mapper.Map<ReservationGET>(created);
        await _imageService.AttachThumbnails(new[] { mapped });

        return Ok(new BaseResponse<ReservationGET>("Reservation created successfully and is awaiting the accommodation owner's response.", mapped));
    }

    
    private static bool IsConcurrentBookingConflict(Exception exception)
    {
        for (var current = exception; current != null; current = current.InnerException)
            if (current is SqlException sql && sql.Number == SqlDeadlockVictim)
                return true;

        return false;
    }

    [HttpPatch]
    [Route("Status")]
    public async Task<IActionResult> ChangeStatus([FromBody] ReservationStatusPATCH statusDto)
    {
        var reservation = await _reservationService.ChangeStatus(statusDto.ReservationId, statusDto.Status, statusDto.Reason);

        var updated = await _reservationRepo.Get(r => r.Id == reservation.Id, false,
            r => r.accommodation, r => r.accommodation.AccommodationType, r => r.accommodation.AccommodationDetails, r => r.accommodation.Location, r => r.accommodation.Location.City, r => r.accommodation.Location.City.Country);
        var mapped = _mapper.Map<ReservationGET>(updated);
        await _imageService.AttachThumbnails(new[] { mapped });
        mapped.IsPaid = (await _paymentService.GetForReservation(reservation.Id))?.Status == PaymentStatus.Completed;

        return Ok(new BaseResponse<ReservationGET>("Reservation status changed successfully.", mapped));
    }

    [HttpGet]
    [Route("History/{id}")]
    public async Task<IActionResult> GetHistory([FromRoute] Guid id)
    {
        var reservation = await _reservationRepo.Get(r => r.Id == id, false, r => r.accommodation);
        if (reservation == null)
            throw new NotFoundException($"Reservation with identifier {id} does not exist.");

        await EnsureCallerIsInvolved(reservation);

        var history = await _reservationService.GetHistory(id);
        var mapped = _mapper.Map<List<ReservationStatusHistoryGET>>(history);
        await _historyActorService.AttachActors(mapped);

        return Ok(new BaseResponse<List<ReservationStatusHistoryGET>>("Reservation history retrieved successfully.", mapped));
    }

    [HttpGet]
    [Route("CheckAvailability")]
    public async Task<IActionResult> CheckAvailability([FromQuery] Guid accommodationId)
    {
        var accommodation = await _accommodationRepo.Get(c => c.Id == accommodationId, false);
        if (accommodation == null)
            throw new NotFoundException($"Accommodation with identifier {accommodationId} does not exist.");

        var reservations = await _reservationRepo.GetAll(
            r => r.AccommodationId == accommodationId
                 && r.Status != ReservationStatus.Cancelled
                 && r.Status != ReservationStatus.Rejected, false);

        var reservedDates = reservations
            .Select(r => new ReservedDatesDTO { StartDate = r.StartDate, EndDate = r.EndDate })
            .ToList();

        return Ok(new BaseResponse<List<ReservedDatesDTO>>("Reserved dates retrieved successfully.", reservedDates));
    }

    [HttpGet]
    [Route("Customer/GetReservations")]
    public async Task<IActionResult> GetReservations([FromQuery] ReservationStatus? status = null,
                                                     [FromQuery] int page = 1,
                                                     [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var customerId = await _currentUser.GetCustomerIdAsync();
        if (customerId == Guid.Empty)
            throw new BusinessException("The logged-in account is not registered as a customer, so it has no reservations.");

        var (items, totalCount) = await _reservationRepo.GetPaged(
            c => c.CustomerId == customerId && (status == null || c.Status == status), page, pageSize, false,
            c => c.accommodation, c => c.accommodation.AccommodationType, c => c.accommodation.AccommodationDetails, c => c.accommodation.Location, c => c.accommodation.Location.City, c => c.accommodation.Location.City.Country);

        var ratedAccommodationIds = (await _reviewRepo.GetAll(c => c.CustomerId == customerId, false))
            .Select(r => r.AccommodationId)
            .ToHashSet();

        var toReturn = _mapper.Map<List<ReservationGET>>(items);
        var paidReservationIds = await _paymentService.GetPaidReservationIds(toReturn.Select(r => r.Id).ToList());
        await _imageService.AttachThumbnails(toReturn);
        foreach (var reservation in toReturn)
        {
            reservation.IsRated = ratedAccommodationIds.Contains(reservation.AccommodationId);
            reservation.IsPaid = paidReservationIds.Contains(reservation.Id);
        }

        return Ok(new PagedResponse<ReservationGET>("Your reservations retrieved successfully.", toReturn, page, pageSize, totalCount));
    }

    [HttpGet]
    [Route("Partner/GetReservations")]
    public async Task<IActionResult> GetPartnerReservations([FromQuery] ReservationStatus? status = null,
                                                            [FromQuery] int page = 1,
                                                            [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var partnerId = await _currentUser.GetPartnerIdAsync();
        if (partnerId == Guid.Empty)
            throw new BusinessException("The logged-in account is not registered as a partner, so it has no accommodation reservations.");

        var (items, totalCount) = await _reservationRepo.GetPaged(
            r => r.accommodation.OwnerId == partnerId && (status == null || r.Status == status), page, pageSize, false,
            r => r.accommodation, r => r.accommodation.AccommodationType, r => r.accommodation.AccommodationDetails, r => r.accommodation.Location, r => r.accommodation.Location.City, r => r.accommodation.Location.City.Country);

        var toReturn = _mapper.Map<List<ReservationGET>>(items);
        var paidReservationIds = await _paymentService.GetPaidReservationIds(toReturn.Select(r => r.Id).ToList());
        await _imageService.AttachThumbnails(toReturn);
        await _guestService.AttachGuests(toReturn);
        foreach (var reservation in toReturn)
        {
            reservation.IsPaid = paidReservationIds.Contains(reservation.Id);
        }

        return Ok(new PagedResponse<ReservationGET>("Reservations for your accommodations retrieved successfully.", toReturn, page, pageSize, totalCount));
    }

    private async Task EnsureCallerIsInvolved(Reservation reservation)
    {
        if (_currentUser.Role == Roles.Administrator)
            return;

        var customerId = await _currentUser.GetCustomerIdAsync();
        if (customerId != Guid.Empty && reservation.CustomerId == customerId)
            return;

        var partnerId = await _currentUser.GetPartnerIdAsync();
        if (partnerId != Guid.Empty && reservation.accommodation != null && reservation.accommodation.OwnerId == partnerId)
            return;

        throw new BusinessException("This reservation does not belong to you.");
    }
}
