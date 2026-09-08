namespace Database.Services.PaymentService;

public class PaymentSummary
{
    public Guid ReservationId { get; set; }
    public Guid PaymentId { get; set; }
    public string AccommodationName { get; set; } = string.Empty;
    public double PricePerNight { get; set; }
    public int Nights { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = string.Empty;
    public bool IsPaid { get; set; }
}
