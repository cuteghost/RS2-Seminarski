using API.Exceptions;
using Database.Services.AccommodationCatalogService;
using Database.Services.AccommodationImageService;
using Microsoft.EntityFrameworkCore;
using Models.Domain;

namespace Database.Services.AccommodationWriteService;

public class AccommodationWriteService : IAccommodationWriteService
{
    private readonly ApplicationDbContext _context;
    private readonly IAccommodationImageService _images;
    private readonly IAccommodationCatalogService _catalog;

    public AccommodationWriteService(ApplicationDbContext context,
                                     IAccommodationImageService images,
                                     IAccommodationCatalogService catalog)
    {
        _context = context;
        _images = images;
        _catalog = catalog;
    }

    public async Task Update(Accommodation accommodation,
                             AccommodationImages? images,
                             AccommodationDetailsUpdate? details,
                             AccommodationLocationUpdate? location)
    {
        var existing = await _context.Accommodations
            .Include(a => a.AccommodationDetails)
            .Include(a => a.Location)
            .FirstOrDefaultAsync(a => a.Id == accommodation.Id && !a.IsDeleted);

        if (existing == null)
            throw new NotFoundException($"Accommodation with identifier {accommodation.Id} does not exist.");

        await using var transaction = await _context.Database.BeginTransactionAsync();

        existing.Name = accommodation.Name;
        existing.Status = accommodation.Status;
        existing.AccommodationTypeId = accommodation.AccommodationTypeId;
        existing.PricePerNight = accommodation.PricePerNight;
        existing.Description = accommodation.Description;

        if (details != null && existing.AccommodationDetails != null)
            existing.AccommodationDetails.NumberOfBeds = details.NumberOfBeds;

        if (location != null)
        {
            if (existing.Location == null)
                throw new BusinessException("Accommodation has no location record so the address cannot be changed.");

            existing.Location.Address = location.Address;
            existing.Location.Latitude = location.Latitude;
            existing.Location.Longitude = location.Longitude;
            existing.Location.CityId = location.CityId;
        }

        await _context.SaveChangesAsync();

        if (images != null)
            await _images.Replace(existing.Id, images);

        if (details != null && existing.AccommodationDetails != null)
            await _catalog.SetAmenities(existing.AccommodationDetails.Id, details.AmenityIds);

        await transaction.CommitAsync();
    }

    public async Task SetStatus(Guid accommodationId, bool status)
    {
        var existing = await _context.Accommodations
            .FirstOrDefaultAsync(a => a.Id == accommodationId && !a.IsDeleted);

        if (existing == null)
            throw new NotFoundException($"Accommodation with identifier {accommodationId} does not exist.");

        if (existing.Status == status)
            return;

        existing.Status = status;
        await _context.SaveChangesAsync();
    }
}
