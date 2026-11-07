using API.Exceptions;
using Database.Services.AccommodationImageService;
using Microsoft.EntityFrameworkCore;
using Models.Domain;

namespace Database.Services.AccommodationWriteService;

public class AccommodationWriteService : IAccommodationWriteService
{
    private readonly ApplicationDbContext _context;
    private readonly IAccommodationImageService _images;

    public AccommodationWriteService(ApplicationDbContext context, IAccommodationImageService images)
    {
        _context = context;
        _images = images;
    }

    public async Task<Guid> Create(Guid ownerId,
                                   AccommodationInput input,
                                   AccommodationDetailsUpdate? details,
                                   AccommodationLocationUpdate? location,
                                   AccommodationImages? images)
    {
        if (details == null)
            throw new BusinessException("Accommodation details (number of beds and amenities) are required.");

        if (location == null)
            throw new BusinessException("Accommodation location is required.");

        if (images == null)
            throw new BusinessException($"Accommodation must have the first {AccommodationImageRules.RequiredImageCount} images filled in.");

        var core = AccommodationRules.Normalize(input);
        var normalizedDetails = AccommodationRules.Normalize(details);
        var normalizedLocation = AccommodationRules.Normalize(location);
        AccommodationImageRules.EnsureValid(images);

        await EnsureReferencesExist(core.AccommodationTypeId, normalizedLocation.CityId, normalizedDetails.AmenityIds);

        await using var transaction = await _context.Database.BeginTransactionAsync();

        var detailsId = Guid.NewGuid();
        images.AccommodationImagesId = Guid.NewGuid();
        images.IsDeleted = false;

        var accommodation = new Accommodation
        {
            Id = Guid.NewGuid(),
            OwnerId = ownerId,
            Name = core.Name,
            Description = core.Description,
            PricePerNight = core.PricePerNight,
            AccommodationTypeId = core.AccommodationTypeId,
            Status = false,
            IsDeleted = false,
            CreatedAt = DateTime.UtcNow,
            AccommodationDetails = new AccommodationDetails
            {
                Id = detailsId,
                NumberOfBeds = normalizedDetails.NumberOfBeds
            },
            Location = new Location
            {
                Id = Guid.NewGuid(),
                Address = normalizedLocation.Address,
                Latitude = normalizedLocation.Latitude,
                Longitude = normalizedLocation.Longitude,
                CityId = normalizedLocation.CityId
            },
            AccommodationImages = images
        };

        _context.Accommodations.Add(accommodation);

        foreach (var amenityId in normalizedDetails.AmenityIds)
        {
            _context.AccommodationDetailsAmenities.Add(new AccommodationDetailsAmenity
            {
                AccommodationDetailsId = detailsId,
                AmenityId = amenityId
            });
        }

        await _context.SaveChangesAsync();
        await transaction.CommitAsync();

        return accommodation.Id;
    }

    public async Task Update(Guid accommodationId,
                             AccommodationInput input,
                             AccommodationImages? images,
                             AccommodationDetailsUpdate? details,
                             AccommodationLocationUpdate? location)
    {
        var core = AccommodationRules.Normalize(input);
        var normalizedDetails = details != null ? AccommodationRules.Normalize(details) : null;
        var normalizedLocation = location != null ? AccommodationRules.Normalize(location) : null;
        if (images != null)
            AccommodationImageRules.EnsureValid(images);

        await EnsureReferencesExist(core.AccommodationTypeId, normalizedLocation?.CityId, normalizedDetails?.AmenityIds);

        var existing = await _context.Accommodations
            .Include(a => a.AccommodationDetails)
            .Include(a => a.Location)
            .FirstOrDefaultAsync(a => a.Id == accommodationId && !a.IsDeleted);

        if (existing == null)
            throw new NotFoundException($"Accommodation with identifier {accommodationId} does not exist.");

        if (normalizedLocation != null && existing.Location == null)
            throw new BusinessException("Accommodation has no location record so the address cannot be changed.");

        await using var transaction = await _context.Database.BeginTransactionAsync();

        existing.Name = core.Name;
        existing.AccommodationTypeId = core.AccommodationTypeId;
        existing.PricePerNight = core.PricePerNight;
        existing.Description = core.Description;

        if (normalizedDetails != null && existing.AccommodationDetails != null)
        {
            existing.AccommodationDetails.NumberOfBeds = normalizedDetails.NumberOfBeds;
            await ReplaceAmenities(existing.AccommodationDetails.Id, normalizedDetails.AmenityIds);
        }

        if (normalizedLocation != null)
        {
            existing.Location!.Address = normalizedLocation.Address;
            existing.Location.Latitude = normalizedLocation.Latitude;
            existing.Location.Longitude = normalizedLocation.Longitude;
            existing.Location.CityId = normalizedLocation.CityId;
        }

        await _context.SaveChangesAsync();

        if (images != null)
            await _images.Replace(existing.Id, images);

        await transaction.CommitAsync();
    }

    public async Task SetStatus(Guid accommodationId, bool status)
    {
        var existing = await Find(accommodationId);

        if (existing.Status == status)
            return;

        existing.Status = status;
        await _context.SaveChangesAsync();
    }

    public async Task SetPromoted(Guid accommodationId, bool promoted)
    {
        var existing = await Find(accommodationId);

        if (promoted && !existing.Status)
            throw new BusinessException("Only an active accommodation can be promoted.");

        if (existing.IsPromoted == promoted)
            return;

        existing.IsPromoted = promoted;
        existing.PromotedAt = promoted ? DateTime.UtcNow : null;
        await _context.SaveChangesAsync();
    }

    private async Task<Accommodation> Find(Guid accommodationId)
    {
        var existing = await _context.Accommodations
            .FirstOrDefaultAsync(a => a.Id == accommodationId && !a.IsDeleted);

        if (existing == null)
            throw new NotFoundException($"Accommodation with identifier {accommodationId} does not exist.");

        return existing;
    }

    private async Task EnsureReferencesExist(Guid accommodationTypeId, Guid? cityId, IReadOnlyCollection<Guid>? amenityIds)
    {
        if (!await _context.AccommodationTypes.AnyAsync(t => !t.IsDeleted && t.Id == accommodationTypeId))
            throw new NotFoundException($"Accommodation type with identifier {accommodationTypeId} does not exist.");

        if (cityId.HasValue && !await _context.Cities.AnyAsync(c => !c.IsDeleted && c.Id == cityId.Value))
            throw new NotFoundException($"City with identifier {cityId.Value} does not exist.");

        if (amenityIds != null && amenityIds.Count > 0)
        {
            var known = await _context.Amenities
                .Where(a => !a.IsDeleted && amenityIds.Contains(a.Id))
                .Select(a => a.Id)
                .ToListAsync();

            var unknown = amenityIds.Except(known).FirstOrDefault();
            if (unknown != Guid.Empty)
                throw new NotFoundException($"Amenity with identifier {unknown} does not exist.");
        }
    }

    private async Task ReplaceAmenities(Guid accommodationDetailsId, IReadOnlyCollection<Guid> amenityIds)
    {
        var existing = await _context.AccommodationDetailsAmenities
            .Where(x => x.AccommodationDetailsId == accommodationDetailsId)
            .ToListAsync();

        _context.AccommodationDetailsAmenities.RemoveRange(existing.Where(x => !amenityIds.Contains(x.AmenityId)));

        var alreadyLinked = existing.Select(x => x.AmenityId).ToHashSet();
        foreach (var amenityId in amenityIds.Where(id => !alreadyLinked.Contains(id)))
        {
            _context.AccommodationDetailsAmenities.Add(new AccommodationDetailsAmenity
            {
                AccommodationDetailsId = accommodationDetailsId,
                AmenityId = amenityId
            });
        }
    }
}
