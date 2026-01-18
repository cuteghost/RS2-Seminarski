using Models.DTO.ReviewDTO;

namespace Services.ReviewService;

public interface IReviewService
{
    Task CalculateReviewScore(Guid accommodationId);

    Task<(List<AccommodationReviewGET> Items, int TotalCount)> GetForAccommodation(
        Guid accommodationId, int page, int pageSize, bool onlyWithComment);
}
