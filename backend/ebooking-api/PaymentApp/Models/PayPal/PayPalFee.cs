namespace PaymentApp.Models.PayPal;

public sealed class PaypalFee
{
    public string currency_code { get; set; }
    public string value { get; set; }
}
