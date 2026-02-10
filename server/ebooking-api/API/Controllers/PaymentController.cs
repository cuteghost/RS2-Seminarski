using API.Exceptions;
using Authentication.Services.TokenHandlerService;
using AutoMapper;
using Database.Services.PaymentService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.Domain;
using Models.DTO.PaymentDTO;
using Repository.Interfaces;
using Services.CurrentUserService;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class PaymentController : Controller
{
    private readonly IPaymentService _paymentService;
    private readonly IGenericRepository<Reservation> _reservationRepo;
    private readonly ICurrentUserService _currentUser;
    private readonly ITokenHandlerService _tokenHandler;
    private readonly IMapper _mapper;

    public PaymentController(IPaymentService paymentService,
                             IGenericRepository<Reservation> reservationRepo,
                             ICurrentUserService currentUser,
                             ITokenHandlerService tokenHandler,
                             IMapper mapper)
    {
        _paymentService = paymentService;
        _reservationRepo = reservationRepo;
        _currentUser = currentUser;
        _tokenHandler = tokenHandler;
        _mapper = mapper;
    }

    [HttpGet]
    [Route("ByReservation/{reservationId}")]
    public async Task<IActionResult> GetByReservation([FromRoute] Guid reservationId)
    {
        var reservation = await _reservationRepo.Get(r => r.Id == reservationId, false, r => r.accommodation);
        if (reservation == null)
            throw new NotFoundException($"Reservation with identifier {reservationId} does not exist.");

        await EnsureCallerIsInvolved(reservation);

        var payment = await _paymentService.GetForReservation(reservationId);
        if (payment == null)
        {
            var expected = await _paymentService.CalculateAmount(reservationId);

            return Ok(new BaseResponse<PaymentGET>("Payment for this reservation has not been started yet.", new PaymentGET
            {
                ReservationId = reservationId,
                Amount = expected,
                Currency = "USD",
                Provider = "PayPal",
                IsPaid = false
            }));
        }

        var mapped = _mapper.Map<PaymentGET>(payment);
        mapped.IsPaid = payment.Status == PaymentStatus.Completed;

        return Ok(new BaseResponse<PaymentGET>("Payment status retrieved successfully.", mapped));
    }

    [HttpPost]
    [Route("Ticket/{reservationId}")]
    public async Task<IActionResult> CreateTicket([FromRoute] Guid reservationId)
    {
        var customerId = await _currentUser.GetCustomerIdAsync();
        if (customerId == Guid.Empty)
            throw new BusinessException("Only a logged-in customer can make a payment.");

        var reservation = await _reservationRepo.Get(r => r.Id == reservationId);
        if (reservation == null)
            throw new NotFoundException($"Reservation with identifier {reservationId} does not exist.");

        if (reservation.CustomerId != customerId)
            throw new BusinessException("This reservation does not belong to you.");

        var ticket = await _tokenHandler.CreatePaymentTicketAsync(_currentUser.UserId, reservationId);
        if (string.IsNullOrEmpty(ticket))
            throw new BusinessException("The payment ticket could not be issued. Please log in again.");

        return Ok(new BaseResponse<string>("Payment ticket issued.", ticket));
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
