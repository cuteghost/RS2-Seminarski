using API.Exceptions;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Models.DTO.AccommodationDTO;
using Models.DTO.ReservationDTO;

namespace Database.Services.AccommodationImageService;

public class AccommodationImageService : IAccommodationImageService
{
    private const string ImagesForeignKey = "AccommodationImagesId";
    private const int RequiredImageCount = 5;

    private readonly ApplicationDbContext _context;

    public AccommodationImageService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Dictionary<Guid, List<int>>> GetImageIndexes(IReadOnlyCollection<Guid> accommodationIds)
    {
        if (accommodationIds.Count == 0)
            return new Dictionary<Guid, List<int>>();

        var rows = await _context.Accommodations
            .AsNoTracking()
            .Where(a => accommodationIds.Contains(a.Id) && a.AccommodationImages != null)
            .Select(a => new AccommodationImageSlots
            {
                AccommodationId = a.Id,
                    Has1 = a.AccommodationImages.Image1 != null && a.AccommodationImages.Image1.Length > 0,
                    Has2 = a.AccommodationImages.Image2 != null && a.AccommodationImages.Image2.Length > 0,
                    Has3 = a.AccommodationImages.Image3 != null && a.AccommodationImages.Image3.Length > 0,
                    Has4 = a.AccommodationImages.Image4 != null && a.AccommodationImages.Image4.Length > 0,
                    Has5 = a.AccommodationImages.Image5 != null && a.AccommodationImages.Image5.Length > 0,
                    Has6 = a.AccommodationImages.Image6 != null && a.AccommodationImages.Image6.Length > 0,
                    Has7 = a.AccommodationImages.Image7 != null && a.AccommodationImages.Image7.Length > 0,
                    Has8 = a.AccommodationImages.Image8 != null && a.AccommodationImages.Image8.Length > 0,
                    Has9 = a.AccommodationImages.Image9 != null && a.AccommodationImages.Image9.Length > 0,
                    Has10 = a.AccommodationImages.Image10 != null && a.AccommodationImages.Image10.Length > 0,
                    Has11 = a.AccommodationImages.Image11 != null && a.AccommodationImages.Image11.Length > 0,
                    Has12 = a.AccommodationImages.Image12 != null && a.AccommodationImages.Image12.Length > 0,
                    Has13 = a.AccommodationImages.Image13 != null && a.AccommodationImages.Image13.Length > 0,
                    Has14 = a.AccommodationImages.Image14 != null && a.AccommodationImages.Image14.Length > 0,
                    Has15 = a.AccommodationImages.Image15 != null && a.AccommodationImages.Image15.Length > 0,
                    Has16 = a.AccommodationImages.Image16 != null && a.AccommodationImages.Image16.Length > 0,
                    Has17 = a.AccommodationImages.Image17 != null && a.AccommodationImages.Image17.Length > 0,
                    Has18 = a.AccommodationImages.Image18 != null && a.AccommodationImages.Image18.Length > 0,
                    Has19 = a.AccommodationImages.Image19 != null && a.AccommodationImages.Image19.Length > 0,
                    Has20 = a.AccommodationImages.Image20 != null && a.AccommodationImages.Image20.Length > 0,
            })
            .ToListAsync();

        return rows.ToDictionary(r => r.AccommodationId, r => r.Indexes());
    }

    public async Task<byte[]?> GetImage(Guid accommodationId, int index)
    {
        if (index < 1 || index > 20)
            return null;

        var query = _context.Accommodations
            .AsNoTracking()
            .Where(a => a.Id == accommodationId && !a.IsDeleted && a.AccommodationImages != null);

        var bytes = index switch
        {
            1 => await query.Select(a => a.AccommodationImages!.Image1).FirstOrDefaultAsync(),
            2 => await query.Select(a => a.AccommodationImages!.Image2).FirstOrDefaultAsync(),
            3 => await query.Select(a => a.AccommodationImages!.Image3).FirstOrDefaultAsync(),
            4 => await query.Select(a => a.AccommodationImages!.Image4).FirstOrDefaultAsync(),
            5 => await query.Select(a => a.AccommodationImages!.Image5).FirstOrDefaultAsync(),
            6 => await query.Select(a => a.AccommodationImages!.Image6).FirstOrDefaultAsync(),
            7 => await query.Select(a => a.AccommodationImages!.Image7).FirstOrDefaultAsync(),
            8 => await query.Select(a => a.AccommodationImages!.Image8).FirstOrDefaultAsync(),
            9 => await query.Select(a => a.AccommodationImages!.Image9).FirstOrDefaultAsync(),
            10 => await query.Select(a => a.AccommodationImages!.Image10).FirstOrDefaultAsync(),
            11 => await query.Select(a => a.AccommodationImages!.Image11).FirstOrDefaultAsync(),
            12 => await query.Select(a => a.AccommodationImages!.Image12).FirstOrDefaultAsync(),
            13 => await query.Select(a => a.AccommodationImages!.Image13).FirstOrDefaultAsync(),
            14 => await query.Select(a => a.AccommodationImages!.Image14).FirstOrDefaultAsync(),
            15 => await query.Select(a => a.AccommodationImages!.Image15).FirstOrDefaultAsync(),
            16 => await query.Select(a => a.AccommodationImages!.Image16).FirstOrDefaultAsync(),
            17 => await query.Select(a => a.AccommodationImages!.Image17).FirstOrDefaultAsync(),
            18 => await query.Select(a => a.AccommodationImages!.Image18).FirstOrDefaultAsync(),
            19 => await query.Select(a => a.AccommodationImages!.Image19).FirstOrDefaultAsync(),
            20 => await query.Select(a => a.AccommodationImages!.Image20).FirstOrDefaultAsync(),
            _ => null
        };

        return bytes != null && bytes.Length > 0 ? bytes : null;
    }

    public async Task Replace(Guid accommodationId, AccommodationImages images)
    {
        var required = new[] { images.Image1, images.Image2, images.Image3, images.Image4, images.Image5 };
        if (required.Any(image => image == null || image.Length == 0))
            throw new BusinessException($"Accommodation must have the first {RequiredImageCount} images filled in. Send images 1 to {RequiredImageCount}; the remaining 15 slots are optional.");

        var accommodation = await _context.Accommodations
            .FirstOrDefaultAsync(a => a.Id == accommodationId && !a.IsDeleted);

        if (accommodation == null)
            throw new NotFoundException($"Accommodation with identifier {accommodationId} does not exist.");

        var imagesId = (Guid?)_context.Entry(accommodation).Property(ImagesForeignKey).CurrentValue;

        if (imagesId.HasValue)
        {
            images.AccommodationImagesId = imagesId.Value;
            images.IsDeleted = false;
            _context.Set<AccommodationImages>().Update(images);
        }
        else
        {
            images.AccommodationImagesId = Guid.NewGuid();
            images.IsDeleted = false;
            accommodation.AccommodationImages = images;
        }

        await _context.SaveChangesAsync();
    }

    public async Task Attach(IReadOnlyCollection<AccommodationGET> accommodations)
    {
        if (accommodations.Count == 0)
            return;

        var indexes = await GetImageIndexes(accommodations.Select(a => a.Id).ToList());

        foreach (var accommodation in accommodations)
        {
            var slots = indexes.TryGetValue(accommodation.Id, out var found) ? found : new List<int>();

            accommodation.ImageCount = slots.Count;
            accommodation.ImageUrls = slots.Select(i => AccommodationImageUrl.For(accommodation.Id, i)).ToList();
        }
    }

    public async Task AttachThumbnails(IReadOnlyCollection<ReservationGET> reservations)
    {
        if (reservations.Count == 0)
            return;

        var accommodationIds = reservations.Select(r => r.AccommodationId).Distinct().ToList();
        var indexes = await GetImageIndexes(accommodationIds);

        foreach (var reservation in reservations)
        {
            var slots = indexes.TryGetValue(reservation.AccommodationId, out var found) ? found : new List<int>();

            reservation.ThumbnailUrl = slots.Count > 0
                ? AccommodationImageUrl.For(reservation.AccommodationId, slots[0])
                : null;

            if (reservation.accommodation != null)
            {
                reservation.accommodation.ImageCount = slots.Count;
                reservation.accommodation.ImageUrls = slots.Select(i => AccommodationImageUrl.For(reservation.AccommodationId, i)).ToList();
            }
        }
    }
}
