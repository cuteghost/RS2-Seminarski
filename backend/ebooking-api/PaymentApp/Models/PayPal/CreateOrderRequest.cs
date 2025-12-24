namespace PaymentApp.Models.PayPal;

public sealed class CreateOrderRequest
{
    public string intent { get; set; }
    public List<PurchaseUnit> purchase_units { get; set; } = new();
}
