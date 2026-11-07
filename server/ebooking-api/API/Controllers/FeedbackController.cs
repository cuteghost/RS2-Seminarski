using API.Exceptions;
using AutoMapper;
using Database.Services.ProfanityFilterService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.Domain;
using Models.DTO.ReviewDTO;
using Repository.Interfaces;
using Services.CurrentUserService;
using Services.ReviewService;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class FeedbackController : Controller
{
    private const int MinimumRating = 1;
    private const int MaximumRating = 10;
    private const int MaximumCommentLength = 1000;

    private readonly IGenericRepository<Review> _reviewRepo;
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IReviewService _reviewService;
    private readonly ICurrentUserService _currentUser;
    private readonly IProfanityFilterService _profanityFilter;
    private readonly IMapper _mapper;

    public FeedbackController(IGenericRepository<Review> reviewRepo,
                              IGenericRepository<Accommodation> accommodationRepo,
                              IReviewService reviewService,
                              ICurrentUserService currentUser,
                              IProfanityFilterService profanityFilter,
                              IMapper mapper)
    {
        _reviewRepo = reviewRepo;
        _accommodationRepo = accommodationRepo;
        _reviewService = reviewService;
        _currentUser = currentUser;
        _profanityFilter = profanityFilter;
        _mapper = mapper;
    }

    [HttpGet]
    [Route("ByAccommodation/{accommodationId}")]
    public async Task<IActionResult> GetByAccommodation([FromRoute] Guid accommodationId,
                                                        [FromQuery] bool onlyWithComment = true,
                                                        [FromQuery] int page = 1,
                                                        [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        var exists = await _accommodationRepo.Any(a => a.Id == accommodationId);
        if (!exists)
            throw new NotFoundException($"Accommodation with identifier {accommodationId} does not exist.");

        var (normalizedPage, normalizedPageSize) = Pagination.Normalize(page, pageSize);

        var (items, totalCount) = await _reviewService.GetForAccommodation(
            accommodationId, normalizedPage, normalizedPageSize, onlyWithComment);

        return Ok(new PagedResponse<AccommodationReviewGET>(
            "Reviews retrieved successfully.", items, normalizedPage, normalizedPageSize, totalCount));
    }

    [HttpGet]
    [Route("Mine/{accommodationId}")]
    public async Task<IActionResult> GetMine([FromRoute] Guid accommodationId, [FromQuery] Guid? reservationId = null)
    {
        var customerId = await _currentUser.GetCustomerIdAsync();
        if (customerId == Guid.Empty)
            throw new BusinessException("Only a logged-in customer can read a review.");

        var exists = await _accommodationRepo.Any(a => a.Id == accommodationId);
        if (!exists)
            throw new NotFoundException($"Accommodation with identifier {accommodationId} does not exist.");

        var reviews = await _reviewRepo.GetAll(r => r.AccommodationId == accommodationId
                                                    && r.CustomerId == customerId
                                                    && (reservationId == null || r.ReservationId == reservationId), false);
        var review = reviews.OrderByDescending(r => r.Id).FirstOrDefault();
        if (review == null)
            throw new NotFoundException("You have not left a review for this stay.");

        return Ok(new BaseResponse<ReviewGET>("Your review retrieved successfully.", await ToDto(review)));
    }

    [HttpGet]
    [Route("Image/{reviewId}")]
    public async Task<IActionResult> GetImage([FromRoute] Guid reviewId)
    {
        var bytes = await _reviewService.GetImage(reviewId);
        if (bytes == null)
            throw new NotFoundException($"Review {reviewId} has no image.");

        var contentType = bytes.Length > 1 && bytes[0] == 0x89 ? "image/png" : "image/jpeg";
        return File(bytes, contentType);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ReviewPOST reviewDto)
    {
        if (reviewDto.Rating < MinimumRating || reviewDto.Rating > MaximumRating)
            throw new BusinessException($"Rating must be a whole number from {MinimumRating} to {MaximumRating}.");

        var comment = reviewDto.Comment?.Trim() ?? string.Empty;
        if (comment.Length > MaximumCommentLength)
            throw new BusinessException($"Review comment must not exceed {MaximumCommentLength} characters.");

        if (reviewDto.ReservationId == Guid.Empty)
            throw new BusinessException("A review must refer to a completed reservation.");

        var customerId = await _currentUser.GetCustomerIdAsync();
        if (customerId == Guid.Empty)
            throw new BusinessException("Only a logged-in customer can leave a review.");

        var (cleanedComment, wasModified) = _profanityFilter.Filter(comment);

        var review = await _reviewService.Create(customerId, reviewDto.ReservationId, reviewDto.AccommodationId,
            reviewDto.Rating, reviewDto.Satisfaction, reviewDto.WouldRecommend, cleanedComment, reviewDto.Image);

        var message = wasModified
            ? "Review saved successfully. The comment was modified because it contained inappropriate content."
            : "Review saved successfully.";

        return Ok(new BaseResponse<ReviewGET>(message, await ToDto(review)));
    }

    private async Task<ReviewGET> ToDto(Review review)
    {
        var dto = _mapper.Map<ReviewGET>(review);
        var withImage = await _reviewService.GetReviewIdsWithImage(new[] { review.Id });
        dto.ImageUrl = withImage.Contains(review.Id) ? ReviewImageUrl.For(review.Id) : null;
        return dto;
    }
}
