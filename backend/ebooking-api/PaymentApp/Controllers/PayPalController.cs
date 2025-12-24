using Microsoft.AspNetCore.Mvc;
using PaymentApp.Clients;
using PaymentApp.Models.PayPal;

namespace PaypalCheckoutExample.Controllers;

public class PaypalController : Controller
{
    private readonly PaypalClient _paypalClient;

    public PaypalController(PaypalClient paypalClient)
    {
        this._paypalClient = paypalClient;
    }

    public IActionResult Index([FromQuery]int numberOfDays, [FromQuery] double pricePerNight, [FromQuery] Guid accommodationId, [FromQuery] string accommodationName)
    {
        // ViewBag.ClientId is used to get the Paypal Checkout javascript SDK
        ViewBag.ClientId = _paypalClient.ClientId;
        ViewBag.NumberOfDays = numberOfDays;
        ViewBag.PricePerNight = pricePerNight;
        ViewBag.AccommodationId = accommodationId;
        ViewBag.AccommodationName = accommodationName;
        ViewBag.TotalPrice = numberOfDays * pricePerNight;



        return View();
    }

    [HttpPost]
    public async Task<IActionResult> Order(CancellationToken cancellationToken, [FromBody] Order orderDetails)
    {
        try
        {
            // set the transaction price and 
            var currency = "USD";

            // "reference" is the transaction key
            var reference = Guid.NewGuid().ToString();

            var response = await _paypalClient.CreateOrder((orderDetails.pricePerNight * orderDetails.numberOfDays).ToString(), currency, reference);

            return Ok(response);
        }
        catch (Exception e)
        {
            var error = new
            {
                e.GetBaseException().Message
            };

            return BadRequest(error);
        }
    }

    public async Task<IActionResult> Capture(string orderId, CancellationToken cancellationToken)
    {
        try
        {
            var response = await _paypalClient.CaptureOrder(orderId);

            var reference = response.purchase_units[0].reference_id;

            // Put your logic to save the transaction here
            // You can use the "reference" variable as a transaction key

            return Ok(response);
        }
        catch (Exception e)
        {
            var error = new
            {
                e.GetBaseException().Message
            };

            return BadRequest(error);
        }
    }

    public IActionResult Success()
    {
        return Ok();
    }
}