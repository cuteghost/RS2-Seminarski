using API.Exceptions;
using AutoMapper;
using Database.Services.AccommodationImageService;
using Database.Services.PaymentService;
using Database.Services.ReservationGuestService;
using Database.Services.ReservationHistoryService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.Domain;
using Models.DTO.ReservationDTO;
using Repository.Interfaces;
using Services.CurrentUserService;
using Services.ReservationService;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class ReservationController : Controller
{
    private readonly IGenericRepository<Reservation> _reservationRepo;
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IGenericRepository<Review> _reviewRepo;
    private readonly ICurrentUserService _currentUser;
    private readonly IReservationService _reservationService;
    private readonly IPaymentService _paymentService;
    private readonly IAccommodationImageService _imageService;
    private readonly IReservationGuestService _guestService;
    private readonly IReservationHistoryActorService _historyActorService;
    private readonly IMapper _mapper;

    public ReservationController(IGenericRepository<Reservation> reservationRepo,
                                 ICurrentUserService currentUser,
                                 IReservationService reservationService,
                                 IPaymentService paymentService,
                                 IAccommodationImageService imageService,
                                 IReservationGuestService guestService,
                                 IReservationHistoryActorService historyActorService,
                                 IMapper mapper,
                                 IGenericRepository<Review> reviewRepo,
                                 IGenericRepository<Accommodation> accommodationRepo)
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
        _accommodationRepo = accommodationRepo;
    }

    [HttpPost]
    [Route("Create")]
    public async Task<IActionResult> Create([FromBody] ReservationPOST reservationDto)
    {
        var customerId = await _currentUser.GetCustomerIdAsync();

        var reservation = await _reservationService.Create(customerId, reservationDto.AccommodationId,
            reservationDto.NumberOfGuests, reservationDto.StartDate, reservationDto.EndDate, reservationDto.CheckInTime);

        var created = await _reservationRepo.Get(r => r.Id == reservation.Id, false,
            r => r.accommodation, r => r.accommodation.AccommodationType, r => r.accommodation.AccommodationDetails, r => r.accommodation.Location, r => r.accommodation.Location.City, r => r.accommodation.Location.City.Country);
        var mapped = _mapper.Map<ReservationGET>(created);
        await _imageService.AttachThumbnails(new[] { mapped });

        return Ok(new BaseResponse<ReservationGET>("Reservation created successfully and is awaiting the accommodation owner's response.", mapped));
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

        var reservationIds = items.Select(r => r.Id).ToList();
        var ratedReservationIds = (await _reviewRepo.Project(
                r => r.CustomerId == customerId && r.ReservationId != null && reservationIds.Contains(r.ReservationId.Value),
                r => r.ReservationId!.Value))
            .ToHashSet();

        var toReturn = _mapper.Map<List<ReservationGET>>(items);
        var paidReservationIds = await _paymentService.GetPaidReservationIds(toReturn.Select(r => r.Id).ToList());
        await _imageService.AttachThumbnails(toReturn);
        foreach (var reservation in toReturn)
        {
            reservation.IsRated = ratedReservationIds.Contains(reservation.Id);
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
