using Database;
using Microsoft.EntityFrameworkCore;
using Models.Domain;

namespace Services.RecommendationService;

public class DataPreparationService
{
    public const float ImplicitStayRating = 6f;

    private readonly ApplicationDbContext _context;

    public DataPreparationService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<AccommodationRating>> GetTrainingData()
    {
        var today = DateTime.UtcNow.Date;

        var rows = await _context.Reviews
            .AsNoTracking()
            .Where(r => !r.IsDeleted)
            .Select(r => new AccommodationRating
            {
                CustomerId = r.CustomerId.ToString(),
                AccommodationId = r.AccommodationId.ToString(),
                Rating = r.Rating
            })
            .ToListAsync();

        var stays = await _context.Reservations
            .AsNoTracking()
            .Where(r => !r.IsDeleted && r.Status == ReservationStatus.Completed && r.EndDate < today)
            .Select(r => new AccommodationRating
            {
                CustomerId = r.CustomerId.ToString(),
                AccommodationId = r.AccommodationId.ToString(),
                Rating = ImplicitStayRating
            })
            .ToListAsync();

        var seen = rows.Select(r => (r.CustomerId, r.AccommodationId)).ToHashSet();
        rows.AddRange(stays.Where(s => seen.Add((s.CustomerId, s.AccommodationId))));

        return rows;
    }
}
