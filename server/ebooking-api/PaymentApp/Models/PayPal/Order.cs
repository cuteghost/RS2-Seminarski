namespace PaymentApp.Models.PayPal;

public class Order
{
    public int numberOfDays { get; set; }
    public double pricePerNight { get; set; }
    public Guid accommodationId { get; set; }
    public string accommodationName { get; set; }

}
