using AutoMapper;
using Database.Services.AccommodationCatalogService;
using Database.Services.AccommodationImageService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.Domain;
using Models.DTO.AccommodationDTO;
using Repository.Interfaces;
using Services.CurrentUserService;
using Services.RecommendationService;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class RecommendationController : ControllerBase
{
    private readonly RecommendationService _recommendationService;
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly ICurrentUserService _currentUser;
    private readonly IAccommodationImageService _imageService;
    private readonly IAccommodationCatalogService _catalog;
    private readonly IMapper _mapper;

    public RecommendationController(RecommendationService recommendationService,
                                    IGenericRepository<Accommodation> accommodationRepo,
                                    ICurrentUserService currentUser,
                                    IMapper mapper,
                                    IAccommodationImageService imageService,
                                    IAccommodationCatalogService catalog)
    {
        _recommendationService = recommendationService;
        _accommodationRepo = accommodationRepo;
        _currentUser = currentUser;
        _mapper = mapper;
        _imageService = imageService;
        _catalog = catalog;
    }

    // customerId je ranije stizao iz rute, pa je svako mogao pročitati tuđe preporuke.
    // Sada dolazi iz tokena i ruta ga više ne prima.
    [HttpGet("suggestions")]
    public async Task<IActionResult> GetSuggestions([FromQuery] int page = 1, [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var customerId = await _currentUser.GetCustomerIdAsync();

        var candidates = await _accommodationRepo.Project(
            a => a.Status,
            a => new AccommodationCandidate(a.Id, a.ReviewScore));

        var ranking = _recommendationService.GetRecommendations(customerId, candidates);
        var pageIds = ranking.AccommodationIds.Skip((page - 1) * pageSize).Take(pageSize).ToList();

        var mapped = new List<AccommodationGET>();

        if (pageIds.Count > 0)
        {
            var items = await _accommodationRepo.GetAll(
                a => pageIds.Contains(a.Id) && a.Status, false,
                a => a.AccommodationDetails, a => a.AccommodationType, a => a.Location, a => a.Location.City, a => a.Location.City.Country);

            var byId = items.ToDictionary(a => a.Id);
            var ranked = pageIds.Where(byId.ContainsKey).Select(id => byId[id]).ToList();

            mapped = _mapper.Map<List<AccommodationGET>>(ranked);
            await _imageService.Attach(mapped);
            await _catalog.AttachAmenities(mapped);
        }

        var message = ranking.FromModel
            ? "Recommendations retrieved successfully."
            : "The recommendation model is still being prepared, so the top-rated accommodations are shown instead.";

        return Ok(new PagedResponse<AccommodationGET>(message, mapped, page, pageSize, ranking.AccommodationIds.Count));
    }
}
