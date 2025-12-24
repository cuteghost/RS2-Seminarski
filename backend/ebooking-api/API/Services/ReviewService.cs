using Database;
using Microsoft.EntityFrameworkCore;

namespace Services;

public class ReviewService : IReviewService
{
    private readonly ApplicationDbContext _context;
    public ReviewService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task CalculateReviewScore(Guid AccommodationId)
    {
        var reviews = await _context.Reviews.AsNoTracking().Where(r => r.AccommodationId == AccommodationId).ToListAsync();
        var accommodation = await _context.Accommodations.FirstOrDefaultAsync(a => a.Id == AccommodationId);
        if (accommodation == null)
            return;
        if (reviews.Count == 0)
        {
            accommodation.ReviewScore = 0;
            await _context.SaveChangesAsync();
            return;
        }
        accommodation.ReviewScore = (float)Math.Round(reviews.Average(r => r.Rating), 1);
        await _context.SaveChangesAsync();
    }
}
