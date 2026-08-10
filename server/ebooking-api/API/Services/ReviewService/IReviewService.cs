using Models.Domain;

namespace Services.ReviewService;

public interface IReviewService
{
    Task CalculateReviewScore(Guid AccommodationId);
}
