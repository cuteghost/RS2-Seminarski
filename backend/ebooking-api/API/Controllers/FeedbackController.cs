using Authentication.Services.TokenHandlerService;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.ReviewDTO;
using Repository.Interfaces;
using Services;

namespace Controllers;

[ApiController]
[Route("/api/[controller]")]
public class FeedbackController : Controller
{
    private readonly IGenericRepository<Review> _reviewRepo;
    private readonly IReviewService _reviewService;
    private readonly ITokenHandlerService _tokenHandlerService;
    private readonly IMapper _mapper;

    public FeedbackController(IGenericRepository<Review> reviewRepo,
                              IReviewService reviewService,
                              ITokenHandlerService tokenHandlerService,
                              IMapper mapper)
    {
        _reviewRepo = reviewRepo;
        _reviewService = reviewService;
        _tokenHandlerService = tokenHandlerService;
        _mapper = mapper;
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] ReviewPOST reviewDto, [FromHeader] string Authorization)
    {
        var customerId = _tokenHandlerService.GetCustomerIdFromJWT(Authorization);
        var review = _mapper.Map<Review>(reviewDto);
        review.CustomerId = customerId;
        await _reviewRepo.Add(review);
        await _reviewService.CalculateReviewScore(review.AccommodationId);
        return Ok();
    }

}
