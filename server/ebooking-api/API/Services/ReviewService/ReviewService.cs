using API.Exceptions;
using Database;
using Database.Services.ImageValidation;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Models.DTO.ReviewDTO;

namespace Services.ReviewService;

public class ReviewService : IReviewService
{
    private const int DuplicateKeyRow = 2627;
    private const int DuplicateKeyIndex = 2601;

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

    public async Task<Review> Create(Guid customerId, Guid reservationId, Guid accommodationId, int rating,
                                     bool satisfaction, bool wouldRecommend, string comment, byte[]? image)
    {
        ImageContentValidator.EnsureValid(image, "Review image");

        var reservation = await _context.Reservations
            .FirstOrDefaultAsync(r => r.Id == reservationId && !r.IsDeleted);

        if (reservation == null)
            throw new NotFoundException($"Reservation with identifier {reservationId} does not exist.");

        if (reservation.CustomerId != customerId)
            throw new BusinessException("You can only review a stay you booked yourself.");

        if (accommodationId != Guid.Empty && reservation.AccommodationId != accommodationId)
            throw new BusinessException("The reservation does not belong to this accommodation.");

        if (reservation.Status != ReservationStatus.Completed)
            throw new BusinessException("A review can be left only after the stay has been completed.");

        if (await _context.Reviews.AnyAsync(r => r.ReservationId == reservationId && !r.IsDeleted))
            throw new BusinessException("You have already reviewed this stay.");

        var review = new Review
        {
            Id = Guid.NewGuid(),
            CustomerId = customerId,
            AccommodationId = reservation.AccommodationId,
            ReservationId = reservationId,
            Rating = rating,
            Satisfaction = satisfaction,
            WouldRecommend = wouldRecommend,
            Comment = comment,
            IsDeleted = false
        };

        await using var transaction = await _context.Database.BeginTransactionAsync();

        _context.Reviews.Add(review);

        if (image != null && image.Length > 0)
        {
            _context.Set<ReviewImage>().Add(new ReviewImage
            {
                Id = Guid.NewGuid(),
                ReviewId = review.Id,
                Image = image,
                IsDeleted = false
            });
        }

        reservation.IsRated = true;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateException ex)
            when (ex.InnerException is SqlException sql && (sql.Number == DuplicateKeyRow || sql.Number == DuplicateKeyIndex))
        {
            throw new BusinessException("You have already reviewed this stay.");
        }

        await CalculateReviewScore(review.AccommodationId);
        await transaction.CommitAsync();

        return review;
    }

    public async Task<byte[]?> GetImage(Guid reviewId)
    {
        var image = await _context.Set<ReviewImage>()
            .AsNoTracking()
            .Where(i => i.ReviewId == reviewId && !i.IsDeleted && !i.Review!.IsDeleted)
            .Select(i => i.Image)
            .FirstOrDefaultAsync();

        return image != null && image.Length > 0 ? image : null;
    }

    public async Task<HashSet<Guid>> GetReviewIdsWithImage(IReadOnlyCollection<Guid> reviewIds)
    {
        if (reviewIds.Count == 0)
            return new HashSet<Guid>();

        var ids = await _context.Set<ReviewImage>()
            .AsNoTracking()
            .Where(i => !i.IsDeleted && reviewIds.Contains(i.ReviewId))
            .Select(i => i.ReviewId)
            .ToListAsync();

        return ids.ToHashSet();
    }

    public async Task<(List<AccommodationReviewGET> Items, int TotalCount)> GetForAccommodation(
        Guid accommodationId, int page, int pageSize, bool onlyWithComment)
    {
        var query = _context.Reviews
            .AsNoTracking()
            .Where(r => !r.IsDeleted && r.AccommodationId == accommodationId);

        if (onlyWithComment)
            query = query.Where(r => (r.Comment != null && r.Comment != string.Empty) || (r.Image != null && !r.Image.IsDeleted));

        var totalCount = await query.CountAsync();

        var rows = await query
            .OrderByDescending(r => r.Rating)
            .ThenBy(r => r.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(r => new
            {
                Review = new AccommodationReviewGET
                {
                    Id = r.Id,
                    AccommodationId = r.AccommodationId,
                    CustomerDisplayName = r.Customer.User.DisplayName,
                    Rating = r.Rating,
                    Satisfaction = r.Satisfaction,
                    WouldRecommend = r.WouldRecommend,
                    Comment = r.Comment
                },
                HasImage = r.Image != null && !r.Image.IsDeleted
            })
            .ToListAsync();

        var items = rows.Select(row =>
        {
            row.Review.ImageUrl = row.HasImage ? ReviewImageUrl.For(row.Review.Id) : null;
            return row.Review;
        }).ToList();

        return (items, totalCount);
    }
}
