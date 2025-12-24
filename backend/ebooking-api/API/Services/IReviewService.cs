using Models.Domain;

namespace Services;

public interface IReviewService
{
    Task CalculateReviewScore(Guid AccommodationId);
}
