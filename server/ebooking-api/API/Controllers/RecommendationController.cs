using API.Exceptions;
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
    private readonly RecommendationDataService _data;
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly ICurrentUserService _currentUser;
    private readonly IAccommodationImageService _imageService;
    private readonly IAccommodationCatalogService _catalog;
    private readonly IMapper _mapper;

    public RecommendationController(RecommendationService recommendationService,
                                    RecommendationDataService data,
                                    IGenericRepository<Accommodation> accommodationRepo,
                                    ICurrentUserService currentUser,
                                    IMapper mapper,
                                    IAccommodationImageService imageService,
                                    IAccommodationCatalogService catalog)
    {
        _recommendationService = recommendationService;
        _data = data;
        _accommodationRepo = accommodationRepo;
        _currentUser = currentUser;
        _mapper = mapper;
        _imageService = imageService;
        _catalog = catalog;
    }

    [HttpGet("suggestions")]
    public async Task<IActionResult> GetSuggestions([FromQuery] double? latitude = null,
                                                    [FromQuery] double? longitude = null,
                                                    [FromQuery] int page = 1,
                                                    [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);
        ValidateCoordinates(latitude, longitude);

        var customerId = await _currentUser.GetCustomerIdAsync();
        var profile = await _data.GetCustomerProfile(customerId, latitude, longitude);
        var candidates = await _data.GetActiveCandidates();
        var amenityNames = await _data.GetAmenityNames();

        var ranking = _recommendationService.GetRecommendations(customerId, profile, candidates, amenityNames);
        var mapped = await LoadPage(ranking, page, pageSize);

        var message = ranking.FromModel
            ? "Recommendations retrieved successfully."
            : "The recommendation model is still being prepared, so the recommendations use your history, location and ratings only.";

        return Ok(new PagedResponse<RecommendedAccommodationGET>(message, mapped, page, pageSize, ranking.Items.Count));
    }

    [HttpGet("similar/{accommodationId}")]
    public async Task<IActionResult> GetSimilar([FromRoute] Guid accommodationId,
                                                [FromQuery] int page = 1,
                                                [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var candidates = await _data.GetActiveCandidates();
        var source = candidates.FirstOrDefault(c => c.Id == accommodationId);
        if (source == null)
        {
            var exists = await _accommodationRepo.Any(a => a.Id == accommodationId);
            if (!exists)
                throw new NotFoundException($"Accommodation with identifier {accommodationId} does not exist.");

            return Ok(new PagedResponse<RecommendedAccommodationGET>(
                "The accommodation is not active, so no similar places are suggested.", new List<RecommendedAccommodationGET>(), page, pageSize, 0));
        }

        var customerId = await _currentUser.GetCustomerIdAsync();
        var amenityNames = await _data.GetAmenityNames();

        var ranking = _recommendationService.GetSimilar(customerId, source, candidates, amenityNames);
        var mapped = await LoadPage(ranking, page, pageSize);

        return Ok(new PagedResponse<RecommendedAccommodationGET>("Similar accommodations retrieved successfully.", mapped, page, pageSize, ranking.Items.Count));
    }

    private async Task<List<RecommendedAccommodationGET>> LoadPage(RecommendationRanking ranking, int page, int pageSize)
    {
        var pageItems = ranking.Items.Skip((page - 1) * pageSize).Take(pageSize).ToList();
        if (pageItems.Count == 0)
            return new List<RecommendedAccommodationGET>();

        var pageIds = pageItems.Select(i => i.AccommodationId).ToList();
        var items = await _accommodationRepo.GetAll(
            a => pageIds.Contains(a.Id) && a.Status, false,
            a => a.AccommodationDetails, a => a.AccommodationType, a => a.Location, a => a.Location.City, a => a.Location.City.Country);

        var byId = items.ToDictionary(a => a.Id);
        var mapped = new List<RecommendedAccommodationGET>();

        foreach (var item in pageItems)
        {
            if (!byId.TryGetValue(item.AccommodationId, out var entity))
                continue;

            var dto = _mapper.Map<RecommendedAccommodationGET>(entity);
            dto.Reasons = item.Reasons;
            dto.Reason = item.Reasons.FirstOrDefault() ?? string.Empty;
            dto.RecommendationScore = Math.Round(item.Score, 2);
            mapped.Add(dto);
        }

        await _imageService.Attach(mapped);
        await _catalog.AttachAmenities(mapped);

        return mapped;
    }

    private static void ValidateCoordinates(double? latitude, double? longitude)
    {
        if (latitude.HasValue != longitude.HasValue)
            throw new BusinessException("Latitude and longitude must be sent together.");

        if (latitude is < -90 or > 90 || longitude is < -180 or > 180)
            throw new BusinessException("Coordinates are out of range.");
    }
}
