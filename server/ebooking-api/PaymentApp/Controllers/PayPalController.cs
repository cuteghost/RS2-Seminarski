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

namespace PaymentApp.Controllers;

[Authorize]
public class PaypalController : Controller
{
    private readonly PaypalClient _paypalClient;
    private readonly IPaymentService _paymentService;
    private readonly ILogger<PaypalController> _logger;

    public PaypalController(PaypalClient paypalClient, IPaymentService paymentService, ILogger<PaypalController> logger)
    {
        _paypalClient = paypalClient;
        _paymentService = paymentService;
        _logger = logger;
    }

    public async Task<IActionResult> Index([FromQuery] Guid reservationId, [FromQuery] string? token)
    {
        var ticketReservationId = User.FindFirstValue(TokenHandlerService.ReservationClaim);
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

        _logger.LogInformation(
            "Otvaranje platne stranice: reservationId {ReservationId}, rid iz ulaznice {TicketReservationId}, korisnik {UserId}.",
            reservationId, ticketReservationId ?? "bez rid claima", userId ?? "bez nameidentifier claima");

        try
        {
            EnsureTicketMatches(reservationId);

            var customerId = await ResolveCustomerId();
            var summary = await _paymentService.GetSummary(reservationId, customerId);

            var totalPrice = summary.Amount.ToString("F2", CultureInfo.InvariantCulture);

            ViewBag.ClientId = _paypalClient.ClientId;
            ViewBag.ReservationId = reservationId;
            ViewBag.Token = token ?? string.Empty;
            ViewBag.AccommodationName = summary.AccommodationName;
            ViewBag.PricePerNight = summary.PricePerNight;
            ViewBag.NumberOfDays = summary.Nights;
            ViewBag.TotalPrice = totalPrice;
            ViewBag.Currency = summary.Currency;

            _logger.LogInformation(
                "Platna stranica za rezervaciju {ReservationId} je pripremljena: {Amount} {Currency} za {Nights} noći.",
                reservationId, totalPrice, summary.Currency, summary.Nights);

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
            var customerId = await ResolveCustomerId();
            var payment = await _paymentService.StartPayment(request.ReservationId, customerId);

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
            var settled = await _paymentService.GetByProviderOrder(orderId);
            if (settled != null && settled.Status == PaymentStatus.Completed)
                return Ok(new { reservationId = settled.ReservationId, amount = settled.Amount, status = settled.Status });

            CaptureOrderResponse response;
            try
            {
                response = await _paypalClient.CaptureOrder(orderId);
            }
            catch (PaypalApiException e)
            {
                _logger.LogError(e, "Naplata narudžbe {OrderId} nije uspjela (HTTP {StatusCode}, oznaka {Issue}).",
                    orderId, e.StatusCode, e.Issue ?? "bez oznake");

                await _paymentService.FailPayment(orderId, e.Message);

                return BadRequest(new { message = e.Message });
            }

            if (!string.Equals(response.status, "COMPLETED", StringComparison.OrdinalIgnoreCase))
            {
                var reason = $"PayPal returned order {orderId} in status {response.status ?? "no status"}, but the payment is confirmed only in the COMPLETED status.";

                _logger.LogError("{Reason}", reason);
                await _paymentService.FailPayment(orderId, reason);

                return BadRequest(new { message = reason });
            }

            var capture = response.purchase_units?.FirstOrDefault()?.payments?.captures?.FirstOrDefault();
            if (capture == null)
            {
                var reason = $"PayPal's response for order {orderId} is in status COMPLETED but does not contain a single capture item.";

                _logger.LogError("{Reason}", reason);
                await _paymentService.FailPayment(orderId, reason);

                return BadRequest(new { message = reason });
            }

            var capturedAmount = decimal.Parse(capture.amount.value, CultureInfo.InvariantCulture);
            var payment = await _paymentService.CompletePayment(orderId, capture.id, capturedAmount, capture.amount.currency_code);

            _logger.LogInformation("Plaćanje {PaymentId} za rezervaciju {ReservationId} je naplaćeno.", payment.Id, payment.ReservationId);

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

    private void EnsureTicketMatches(Guid reservationId)
    {
        var raw = User.FindFirstValue(TokenHandlerService.ReservationClaim);
        if (!Guid.TryParse(raw, out var ticketReservationId) || ticketReservationId != reservationId)
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
