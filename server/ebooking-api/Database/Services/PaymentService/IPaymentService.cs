using Models.Domain;

namespace Database.Services.PaymentService;

public interface IPaymentService
{
    Task<Payment> StartPayment(Guid reservationId, Guid customerId);

    Task<Payment> AttachProviderOrder(Guid paymentId, string providerOrderId);

    Task<Payment> CompletePayment(string providerOrderId, string providerCaptureId, decimal capturedAmount, string currency);

    Task<Payment> FailPayment(string providerOrderId, string reason);

    Task<Payment?> GetForReservation(Guid reservationId);

    Task<Payment?> GetByProviderOrder(string providerOrderId);

    Task<HashSet<Guid>> GetPaidReservationIds(IReadOnlyCollection<Guid> reservationIds);

    Task<decimal> CalculateAmount(Guid reservationId);

    Task<Guid> GetCustomerIdForUser(Guid userId);

    Task<PaymentSummary> GetSummary(Guid reservationId, Guid customerId);
}
