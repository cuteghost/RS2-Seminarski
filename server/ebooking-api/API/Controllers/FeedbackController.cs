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

    /// <summary>
    /// Recenzija koju je prijavljeni kupac ostavio za zadati smještaj. Postojeća ruta
    /// <c>ByAccommodation</c> vraća tuđe recenzije, straniči ih i podrazumijevano izostavlja one
    /// bez komentara, pa se vlastita iz nje ne može pouzdano izvaditi.
    /// </summary>
    [HttpGet]
    [Route("Mine/{accommodationId}")]
    public async Task<IActionResult> GetMine([FromRoute] Guid accommodationId)
    {
        var customerId = await _currentUser.GetCustomerIdAsync();
        if (customerId == Guid.Empty)
            throw new BusinessException("Only a logged-in customer can read a review.");

        var exists = await _accommodationRepo.Any(a => a.Id == accommodationId);
        if (!exists)
            throw new NotFoundException($"Accommodation with identifier {accommodationId} does not exist.");

        var review = await _reviewRepo.Get(r => r.AccommodationId == accommodationId && r.CustomerId == customerId, false);
        if (review == null)
            throw new NotFoundException("You have not left a review for this accommodation.");

        return Ok(new BaseResponse<ReviewGET>("Your review retrieved successfully.", _mapper.Map<ReviewGET>(review)));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ReviewPOST reviewDto)
    {
        if (reviewDto.Rating < MinimumRating || reviewDto.Rating > MaximumRating)
            throw new BusinessException($"Rating must be a whole number from {MinimumRating} to {MaximumRating}.");

        if (!string.IsNullOrEmpty(reviewDto.Comment) && reviewDto.Comment.Length > MaximumCommentLength)
            throw new BusinessException($"Review comment must not exceed {MaximumCommentLength} characters.");

        var customerId = await _currentUser.GetCustomerIdAsync();
        if (customerId == Guid.Empty)
            throw new BusinessException("Only a logged-in customer can leave a review.");

        var accommodation = await _accommodationRepo.Get(c => c.Id == reviewDto.AccommodationId, false);
        if (accommodation == null)
            throw new NotFoundException($"Accommodation with identifier {reviewDto.AccommodationId} does not exist.");

        var (cleanedComment, wasModified) = _profanityFilter.Filter(reviewDto.Comment);

        var review = _mapper.Map<Review>(reviewDto);
        review.Id = Guid.NewGuid();
        review.CustomerId = customerId;
        review.Comment = cleanedComment;

        await _reviewRepo.Add(review);
        await _reviewService.CalculateReviewScore(review.AccommodationId);

        var message = wasModified
            ? "Review saved successfully. The comment was modified because it contained inappropriate content."
            : "Review saved successfully.";

        return Ok(new BaseResponse<ReviewGET>(message, _mapper.Map<ReviewGET>(review)));
    }
}
