using Database;
using Microsoft.EntityFrameworkCore;
using Models.DTO.ReviewDTO;

namespace Services.ReviewService;

public class ReviewService : IReviewService
{
    private readonly ApplicationDbContext _context;
    public ReviewService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task CalculateReviewScore(Guid accommodationId)
    {
        var average = await _context.Reviews
            .Where(r => !r.IsDeleted && r.AccommodationId == accommodationId)
            .Select(r => (double?)r.Rating)
            .AverageAsync();

        var score = (float)Math.Round(average ?? 0d, 1);

        await _context.Accommodations
            .Where(a => a.Id == accommodationId)
            .ExecuteUpdateAsync(setters => setters.SetProperty(a => a.ReviewScore, score));
    }

    public async Task<(List<AccommodationReviewGET> Items, int TotalCount)> GetForAccommodation(
        Guid accommodationId, int page, int pageSize, bool onlyWithComment)
    {
        var query = _context.Reviews
            .AsNoTracking()
            .Where(r => !r.IsDeleted && r.AccommodationId == accommodationId);

        if (onlyWithComment)
            query = query.Where(r => r.Comment != null && r.Comment != string.Empty);

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(r => r.Rating)
            .ThenBy(r => r.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(r => new AccommodationReviewGET
            {
                Id = r.Id,
                AccommodationId = r.AccommodationId,
                CustomerDisplayName = r.Customer.User.DisplayName,
                Rating = r.Rating,
                Satisfaction = r.Satisfaction,
                WouldRecommend = r.WouldRecommend,
                Comment = r.Comment
            })
            .ToListAsync();

        return (items, totalCount);
    }
}
