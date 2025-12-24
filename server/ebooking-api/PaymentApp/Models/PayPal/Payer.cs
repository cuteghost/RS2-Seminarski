namespace PaymentApp.Models.PayPal;

public sealed class Payer
{
    public Name name { get; set; }
    public string email_address { get; set; }
    public string payer_id { get; set; }
}
