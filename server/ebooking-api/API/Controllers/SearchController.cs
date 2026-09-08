using API.Exceptions;
using API.Extensions;
using AutoMapper;
using Database.Services.AccommodationCatalogService;
using Database.Services.AccommodationImageService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.Domain;
using Models.DTO.AccommodationDTO;
using Repository.Interfaces;
using Services.ReservationService;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class SearchController : Controller
{
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IReservationService _reservationService;
    private readonly IAccommodationImageService _imageService;
    private readonly IAccommodationCatalogService _catalog;
    private readonly IMapper _mapper;

    public SearchController(IGenericRepository<Accommodation> accommodationRepo,
                            IMapper mapper,
                            IReservationService reservationService,
                            IAccommodationImageService imageService,
                            IAccommodationCatalogService catalog)
    {
        _accommodationRepo = accommodationRepo;
        _mapper = mapper;
        _reservationService = reservationService;
        _imageService = imageService;
        _catalog = catalog;
    }

    [HttpGet]
    public async Task<IActionResult> Search([FromQuery] double priceFrom,
                                            [FromQuery] double priceTo,
                                            [FromQuery] DateTime checkIn,
                                            [FromQuery] DateTime checkOut,
                                            [FromQuery] string? city = null,
                                            [FromQuery] Guid? accommodationTypeId = null,
                                            [FromQuery] double? minReviewScore = null,
                                            [FromQuery] List<string>? amenityIds = null,
                                            [FromQuery] int page = 1,
                                            [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        if (checkOut.Date <= checkIn.Date)
            throw new BusinessException("The check-out date must be after the check-in date, at least one day later.");

        if (priceTo > 0 && priceTo < priceFrom)
            throw new BusinessException("The upper price bound must not be less than the lower bound.");

        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var parsedAmenityIds = ParseAmenityIds(amenityIds);

        var matchesFilters = MatchesFilters(priceFrom, priceTo, city, accommodationTypeId, minReviewScore, parsedAmenityIds);

        // Dostupnost koristi AvailableBetween iz ReservationService (NOT EXISTS podupit) umjesto
        // upita po svakom smještaju i straničenja nad već učitanom listom.
        var predicate = matchesFilters
            .And(c => c.Status)
            .And(_reservationService.AvailableBetween(checkIn, checkOut));

        var (items, totalCount) = await _accommodationRepo.GetPaged(predicate, page, pageSize, false,
            c => c.AccommodationDetails, c => c.AccommodationType, c => c.Location, c => c.Location.City, c => c.Location.City.Country);

        var mapped = _mapper.Map<List<AccommodationGET>>(items);
        await _imageService.Attach(mapped);
        await _catalog.AttachAmenities(mapped);

        return Ok(new PagedResponse<AccommodationGET>("Search results retrieved successfully.", mapped, page, pageSize, totalCount));
    }

    private static List<Guid>? ParseAmenityIds(List<string>? raw)
    {
        if (raw == null || raw.Count == 0)
            return null;

        var ids = new List<Guid>();
        foreach (var entry in raw)
        {
            foreach (var part in entry.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
            {
                if (!Guid.TryParse(part, out var id))
                    throw new BusinessException($"The value \"{part}\" is not a valid identifier. A GUID is expected, e.g. 3fa85f64-5717-4562-b3fc-2c963f66afa6.");
                ids.Add(id);
            }
        }

        return ids.Count > 0 ? ids : null;
    }

    /// <summary>
    /// Cijena i grad. Gornja granica se zanemaruje kad je nula ili manja — klijent koji ne
    /// filtrira po cijeni ne šalje ništa, a to je dosad značilo „ništa nije jeftinije od 0".
    /// Prazan grad znači sve gradove.
    /// </summary>
    private static System.Linq.Expressions.Expression<Func<Accommodation, bool>> MatchesFilters(
        double priceFrom, double priceTo, string? city,
        Guid? accommodationTypeId, double? minReviewScore, List<Guid>? amenityIds)
    {
        var hasUpperBound = priceTo > 0;
        var cityName = string.IsNullOrWhiteSpace(city) ? null : city.Trim();
        var requiredAmenities = amenityIds != null && amenityIds.Count > 0 ? amenityIds : null;
        var requiredAmenityCount = requiredAmenities?.Count ?? 0;

        return accommodation =>
            accommodation.PricePerNight >= priceFrom &&
            (!hasUpperBound || accommodation.PricePerNight <= priceTo) &&
            (cityName == null || (accommodation.Location != null && accommodation.Location.City != null && accommodation.Location.City.Name == cityName)) &&
            (!accommodationTypeId.HasValue || accommodation.AccommodationTypeId == accommodationTypeId.Value) &&
            (!minReviewScore.HasValue || accommodation.ReviewScore >= minReviewScore.Value) &&
            (requiredAmenities == null ||
             (accommodation.AccommodationDetails != null &&
              accommodation.AccommodationDetails.AccommodationDetailsAmenities
                  .Count(x => requiredAmenities.Contains(x.AmenityId)) == requiredAmenityCount));
    }
}
