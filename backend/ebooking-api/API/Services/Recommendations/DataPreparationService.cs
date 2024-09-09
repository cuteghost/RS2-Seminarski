using Database;
using System.Collections.Generic;
using System.Linq;

namespace Services.Recommendations;

public class DataPreparationService
{
    private readonly ApplicationDbContext _context;

    public DataPreparationService(ApplicationDbContext context)
    {
        _context = context;
    }

    public List<AccommodationRating> GetTrainingData()
    {
        var reviews = _context.Reviews
                   .Where(r => !r.IsDeleted)
                   .Select(r => new AccommodationRating
                   {
                       CustomerId = GuidToFloat(r.CustomerId),
                       AccommodationId = GuidToFloat(r.AccommodationId),
                       Rating = r.Accommodation.PricePerNight <= 150 ? 3 : 2,
                       PricePerNight = (float)r.Accommodation.PricePerNight,
                       ReviewScore = r.Accommodation.ReviewScore
                   })
                   .ToList();

        var reservations = _context.Reservations
            .Where(r => !r.IsDeleted && r.EndDate < DateTime.Now)  // Only include completed reservations
            .Select(r => new AccommodationRating
            {
                CustomerId = GuidToFloat(r.CustomerId),
                AccommodationId = GuidToFloat(r.AccommodationId),
                Rating = r.accommodation.PricePerNight <= 150 ? 3 : 2,  // Implicit feedback: consider rated reservations as 3, unrated as 2
                PricePerNight = (float)r.accommodation.PricePerNight,
                ReviewScore = r.accommodation.ReviewScore
            })
            .ToList();

        return reviews.Concat(reservations).ToList(); // Co
    }

    private static float GuidToFloat(Guid guid)
    {
        var bytes = guid.ToByteArray();
        int intValue = BitConverter.ToInt32(bytes, 0);
        return intValue;
    }
}
