using Models.Domain;

namespace Database.Services.PaymentService;

public interface IPaymentService
{
    Task<Payment> StartPayment(Guid reservationId, Guid customerId);

    Task<Payment> AttachProviderOrder(Guid paymentId, string providerOrderId);

    Task<Payment> GetOwnedByProviderOrder(string providerOrderId, Guid reservationId, Guid customerId);

    Task<Payment> CompletePayment(Guid paymentId, string providerCaptureId, decimal capturedAmount, string currency);

    Task<Payment> FailPayment(Guid paymentId, string reason);

    Task<Payment?> GetForReservation(Guid reservationId);

    Task<HashSet<Guid>> GetPaidReservationIds(IReadOnlyCollection<Guid> reservationIds);

    Task<bool> IsPaid(Guid reservationId);

    Task<decimal> CalculateAmount(Guid reservationId);

    Task<Guid> GetCustomerIdForUser(Guid userId);

    Task<PaymentSummary> GetSummary(Guid reservationId, Guid customerId);
}
