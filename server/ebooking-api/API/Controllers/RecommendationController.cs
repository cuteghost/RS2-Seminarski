using AutoMapper;
using Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Models.DTO.AccommodationDTO;
using Services.Recommendations;
using System.Collections.Generic;
using System.Linq;

[Route("api/[controller]")]
[ApiController]
public class RecommendationController : ControllerBase
{
    private readonly RecommendationService _recommendationService;
    private readonly ApplicationDbContext _context;
    private readonly IMapper _mapper;

    public RecommendationController(RecommendationService recommendationService, ApplicationDbContext context, IMapper mapper)
    {
        _recommendationService = recommendationService;
        _context = context;
        _mapper = mapper;
    }

    [HttpGet("suggestions/{customerId}")]
    public IActionResult GetSuggestions(Guid customerId)
    {
        var accommodations = _context.Accommodations.Where(a => !a.IsDeleted).ToList();
        var recommendedAccommodationIds = _recommendationService.GetRecommendations(customerId, accommodations);

        var recommendedAccommodations = _context.Accommodations
            .Where(a => recommendedAccommodationIds.Contains(a.Id))
            .Include(a => a.AccommodationImages)
            .Include(a => a.AccommodationDetails)
            .Include(a => a.Location)
            .ToList();

        return Ok(_mapper.Map<List<AccommodationGET>>(recommendedAccommodations));
    }
}
