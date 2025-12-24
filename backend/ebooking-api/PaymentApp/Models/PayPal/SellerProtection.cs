namespace PaymentApp.Models.PayPal;

public sealed class SellerProtection
{
    public string status { get; set; }
    public List<string> dispute_categories { get; set; }
}
