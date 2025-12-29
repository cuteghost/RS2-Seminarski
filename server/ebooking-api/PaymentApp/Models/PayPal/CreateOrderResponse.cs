namespace PaymentApp.Models.PayPal;

public sealed class CreateOrderResponse
{
    public string id { get; set; }
    public string status { get; set; }
    public List<Link> links { get; set; }
}
