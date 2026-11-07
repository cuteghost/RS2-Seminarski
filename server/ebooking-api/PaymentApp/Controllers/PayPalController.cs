using System.Globalization;
using System.Security.Claims;
using API.Exceptions;
using Authentication.Services.TokenHandlerService;
using Database.Services.PaymentService;
using Models.Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PaymentApp.Clients;
using PaymentApp.Models.PayPal;
using PaymentApp.Services;

namespace PaymentApp.Controllers;

[Authorize]
public class PaypalController : Controller
{
    private readonly PaypalClient _paypalClient;
    private readonly IPaymentService _paymentService;
    private readonly INotificationPublisher _notifications;
    private readonly ILogger<PaypalController> _logger;

    public PaypalController(PaypalClient paypalClient,
                            IPaymentService paymentService,
                            INotificationPublisher notifications,
                            ILogger<PaypalController> logger)
    {
        _paypalClient = paypalClient;
        _paymentService = paymentService;
        _notifications = notifications;
        _logger = logger;
    }

    public async Task<IActionResult> Index([FromQuery] Guid reservationId, [FromQuery] string? token)
    {
        try
        {
            EnsureTicketMatches(reservationId);

            var customerId = await ResolveCustomerId();
            var summary = await _paymentService.GetSummary(reservationId, customerId);

            if (summary.IsPaid)
            {
                ViewBag.ErrorMessage = "The reservation has already been paid.";
                return View("PaymentError");
            }

            var totalPrice = summary.Amount.ToString("F2", CultureInfo.InvariantCulture);

            ViewBag.ClientId = _paypalClient.ClientId;
            ViewBag.ReservationId = reservationId;
            ViewBag.Token = token ?? string.Empty;
            ViewBag.AccommodationName = summary.AccommodationName;
            ViewBag.PricePerNight = summary.PricePerNight;
            ViewBag.NumberOfDays = summary.Nights;
            ViewBag.TotalPrice = totalPrice;
            ViewBag.Currency = summary.Currency;

            return View();
        }
        catch (Exception e) when (e is BusinessException or NotFoundException)
        {
            _logger.LogWarning("Platna stranica za rezervaciju {ReservationId} je odbijena: {Reason}",
                reservationId, e.Message);

            ViewBag.ErrorMessage = e.Message;
            return View("PaymentError");
        }
    }

    [HttpPost]
    public async Task<IActionResult> Order([FromBody] PaymentOrderRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var reservationId = TicketReservationId();
            if (request.ReservationId != reservationId)
                throw new BusinessException("The payment ticket does not belong to this reservation.");

            var customerId = await ResolveCustomerId();
            var payment = await _paymentService.StartPayment(reservationId, customerId);

            var value = payment.Amount.ToString("F2", CultureInfo.InvariantCulture);

            try
            {
                var response = await _paypalClient.CreateOrder(value, payment.Currency, payment.Id.ToString());

                await _paymentService.AttachProviderOrder(payment.Id, response.id);

                return Ok(response);
            }
            catch (PaypalApiException e)
            {
                _logger.LogError(e, "Kreiranje narudžbe za plaćanje {PaymentId} nije uspjelo (HTTP {StatusCode}).",
                    payment.Id, e.StatusCode);

                await _paymentService.FailPayment(payment.Id, e.Message);

                return BadRequest(new { message = e.Message });
            }
        }
        catch (Exception e) when (e is BusinessException or NotFoundException)
        {
            return BadRequest(new { message = e.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> Capture([FromQuery] string orderId, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(orderId))
            return BadRequest(new { message = "Missing order identifier." });

        try
        {
            var reservationId = TicketReservationId();
            var customerId = await ResolveCustomerId();

            var owned = await _paymentService.GetOwnedByProviderOrder(orderId, reservationId, customerId);

            if (owned.Status == PaymentStatus.Completed)
                return Ok(new { reservationId = owned.ReservationId, amount = owned.Amount, status = owned.Status });

            if (owned.Status != PaymentStatus.Created)
                return BadRequest(new { message = "This payment attempt is no longer open. Please start the payment again." });

            CaptureOrderResponse response;
            try
            {
                response = await _paypalClient.CaptureOrder(orderId);
            }
            catch (PaypalApiException e)
            {
                _logger.LogError(e, "Naplata narudžbe {OrderId} nije uspjela (HTTP {StatusCode}, oznaka {Issue}).",
                    orderId, e.StatusCode, e.Issue ?? "bez oznake");

                await _paymentService.FailPayment(owned.Id, e.Message);

                return BadRequest(new { message = e.Message });
            }

            if (!string.Equals(response.status, "COMPLETED", StringComparison.OrdinalIgnoreCase))
            {
                var reason = $"PayPal returned order {orderId} in status {response.status ?? "no status"}, but the payment is confirmed only in the COMPLETED status.";

                _logger.LogError("{Reason}", reason);
                await _paymentService.FailPayment(owned.Id, reason);

                return BadRequest(new { message = reason });
            }

            var capture = response.purchase_units?.FirstOrDefault()?.payments?.captures?.FirstOrDefault();
            if (capture == null)
            {
                var reason = $"PayPal's response for order {orderId} is in status COMPLETED but does not contain a single capture item.";

                _logger.LogError("{Reason}", reason);
                await _paymentService.FailPayment(owned.Id, reason);

                return BadRequest(new { message = reason });
            }

            var capturedAmount = decimal.Parse(capture.amount.value, CultureInfo.InvariantCulture);
            var payment = await _paymentService.CompletePayment(owned.Id, capture.id, capturedAmount, capture.amount.currency_code);

            _logger.LogInformation("Plaćanje {PaymentId} za rezervaciju {ReservationId} je naplaćeno.", payment.Id, payment.ReservationId);

            NotifyPaid(owned);

            return Ok(new { reservationId = payment.ReservationId, amount = payment.Amount, status = payment.Status });
        }
        catch (Exception e) when (e is BusinessException or NotFoundException)
        {
            return BadRequest(new { message = e.Message });
        }
    }

    [AllowAnonymous]
    public IActionResult Success()
    {
        return View();
    }

    private void NotifyPaid(Payment payment)
    {
        var reservation = payment.Reservation;
        var accommodationName = reservation?.accommodation?.Name ?? "your accommodation";
        var amount = $"{payment.Amount.ToString("F2", CultureInfo.InvariantCulture)} {payment.Currency}";

        if (Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var guestUserId))
        {
            _notifications.Publish(new NotificationEvent
            {
                UserId = guestUserId,
                Type = NotificationType.PaymentCompleted,
                Title = "Payment received",
                Body = $"Your payment of {amount} for {accommodationName} was completed successfully.",
                RelatedEntityId = payment.ReservationId,
                CreatedAt = DateTime.UtcNow
            });
        }

        var ownerUserId = reservation?.accommodation?.Owner?.UserId;
        if (ownerUserId.HasValue)
        {
            _notifications.Publish(new NotificationEvent
            {
                UserId = ownerUserId.Value,
                Type = NotificationType.PaymentCompleted,
                Title = "Reservation paid",
                Body = $"The guest paid {amount} for the reservation at {accommodationName}.",
                RelatedEntityId = payment.ReservationId,
                CreatedAt = DateTime.UtcNow
            });
        }
    }

    private Guid TicketReservationId()
    {
        var raw = User.FindFirstValue(TokenHandlerService.ReservationClaim);
        if (!Guid.TryParse(raw, out var ticketReservationId))
            throw new BusinessException("The payment ticket does not identify a reservation.");

        return ticketReservationId;
    }

    private void EnsureTicketMatches(Guid reservationId)
    {
        if (TicketReservationId() != reservationId)
            throw new BusinessException("The payment ticket does not belong to this reservation.");
    }

    private async Task<Guid> ResolveCustomerId()
    {
        var raw = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(raw, out var userId))
            throw new BusinessException("The token does not carry a user identifier. Please log in again.");

        var customerId = await _paymentService.GetCustomerIdForUser(userId);
        if (customerId == Guid.Empty)
            throw new BusinessException("Only a logged-in customer can make this payment.");

        return customerId;
    }
}
