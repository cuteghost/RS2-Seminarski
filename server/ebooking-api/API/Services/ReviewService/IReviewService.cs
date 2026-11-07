using Models.Domain;
using Models.DTO.ReviewDTO;

namespace Services.ReviewService;

public interface IReviewService
{
    Task CalculateReviewScore(Guid accommodationId);

    Task<(List<AccommodationReviewGET> Items, int TotalCount)> GetForAccommodation(
        Guid accommodationId, int page, int pageSize, bool onlyWithComment);

    Task<Review> Create(Guid customerId, Guid reservationId, Guid accommodationId, int rating,
                        bool satisfaction, bool wouldRecommend, string comment, byte[]? image);

    Task<byte[]?> GetImage(Guid reviewId);

    Task<HashSet<Guid>> GetReviewIdsWithImage(IReadOnlyCollection<Guid> reviewIds);
}
