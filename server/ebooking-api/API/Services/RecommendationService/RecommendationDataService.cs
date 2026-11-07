using Database;
using Microsoft.EntityFrameworkCore;
using Models.Domain;

namespace Services.RecommendationService;

public class RecommendationDataService
{
    private readonly ApplicationDbContext _context;

    public RecommendationDataService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<AccommodationCandidate>> GetActiveCandidates()
    {
        var rows = await _context.Accommodations
            .AsNoTracking()
            .Where(a => !a.IsDeleted && a.Status)
            .Select(a => new
            {
                a.Id,
                a.ReviewScore,
                CityId = a.Location != null ? a.Location.CityId : null,
                CityName = a.Location != null && a.Location.City != null ? a.Location.City.Name : string.Empty,
                a.AccommodationTypeId,
                TypeName = a.AccommodationType != null ? a.AccommodationType.Name : string.Empty,
                a.PricePerNight,
                Latitude = a.Location != null ? (double?)a.Location.Latitude : null,
                Longitude = a.Location != null ? (double?)a.Location.Longitude : null,
                AmenityIds = a.AccommodationDetails != null
                    ? a.AccommodationDetails.AccommodationDetailsAmenities.Select(x => x.AmenityId).ToList()
                    : new List<Guid>()
            })
            .ToListAsync();

        return rows.Select(r => new AccommodationCandidate(
                r.Id, r.ReviewScore, r.CityId, r.CityName, r.AccommodationTypeId, r.TypeName,
                r.PricePerNight, r.Latitude, r.Longitude, r.AmenityIds))
            .ToList();
    }

    public async Task<CustomerProfile> GetCustomerProfile(Guid customerId, double? latitude, double? longitude)
    {
        if (customerId == Guid.Empty)
            return new CustomerProfile(new HashSet<Guid>(), new HashSet<Guid>(), new Dictionary<Guid, int>(), latitude, longitude);

        var stays = await _context.Reservations
            .AsNoTracking()
            .Where(r => !r.IsDeleted && r.CustomerId == customerId
                        && (r.Status == ReservationStatus.Completed || r.Status == ReservationStatus.Confirmed))
            .Select(r => new
            {
                r.AccommodationId,
                CityId = r.accommodation.Location != null ? r.accommodation.Location.CityId : null,
                AmenityIds = r.accommodation.AccommodationDetails != null
                    ? r.accommodation.AccommodationDetails.AccommodationDetailsAmenities.Select(x => x.AmenityId).ToList()
                    : new List<Guid>()
            })
            .ToListAsync();

        var stayed = stays.Select(s => s.AccommodationId).ToHashSet();
        var cities = stays.Where(s => s.CityId.HasValue).Select(s => s.CityId!.Value).ToHashSet();
        var amenityFrequency = stays
            .SelectMany(s => s.AmenityIds)
            .GroupBy(id => id)
            .ToDictionary(g => g.Key, g => g.Count());

        return new CustomerProfile(stayed, cities, amenityFrequency, latitude, longitude);
    }

    public async Task<Dictionary<Guid, string>> GetAmenityNames()
    {
        return await _context.Amenities
            .AsNoTracking()
            .Where(a => !a.IsDeleted)
            .ToDictionaryAsync(a => a.Id, a => a.Name);
    }
}
