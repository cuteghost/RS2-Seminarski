using API.Exceptions;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Models.Constants;
using Models.Domain;
using Models.DTO.AccommodationDTO;
using Models.DTO.AccommodationTypeDTO;
using Models.DTO.AmenityDTO;

namespace Database.Services.AccommodationCatalogService;

public class AccommodationCatalogService : IAccommodationCatalogService
{
    private const int MinTextLength = 2;
    private const int DuplicateKeyRow = 2627;
    private const int DuplicateKeyIndex = 2601;

    private readonly ApplicationDbContext _context;

    public AccommodationCatalogService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<BaseResponse<AccommodationTypeGET>> CreateType(AccommodationTypePOST type)
    {
        var name = Normalize(type.Name, "Accommodation type name");
        await EnsureTypeNameIsFree(name, Guid.Empty);

        var entity = new AccommodationType
        {
            Id = Guid.NewGuid(),
            Name = name,
            SortOrder = type.SortOrder,
            IsDeleted = false
        };

        _context.AccommodationTypes.Add(entity);
        await SaveUnique(TypeNameTaken(name));

        return new BaseResponse<AccommodationTypeGET>("Accommodation type successfully added.", ToDto(entity));
    }

    public async Task<BaseResponse<List<AccommodationTypeGET>>> GetTypes(int page, int pageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var query = _context.AccommodationTypes.AsNoTracking().Where(t => !t.IsDeleted);
        var totalCount = await query.CountAsync();
        var items = await query
            .OrderBy(t => t.SortOrder).ThenBy(t => t.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(t => new AccommodationTypeGET { Id = t.Id, Name = t.Name, SortOrder = t.SortOrder })
            .ToListAsync();

        return new PagedResponse<AccommodationTypeGET>("Accommodation types successfully retrieved.", items, page, pageSize, totalCount);
    }

    public async Task<BaseResponse<AccommodationTypeGET>> GetType(Guid id)
    {
        var entity = await FindType(id);

        return new BaseResponse<AccommodationTypeGET>("Accommodation type successfully retrieved.", ToDto(entity));
    }

    public async Task<BaseResponse<AccommodationTypeGET>> UpdateType(AccommodationTypePATCH type)
    {
        var entity = await FindType(type.Id);
        var name = Normalize(type.Name, "Accommodation type name");
        await EnsureTypeNameIsFree(name, type.Id);

        entity.Name = name;
        entity.SortOrder = type.SortOrder;
        await SaveUnique(TypeNameTaken(name));

        return new BaseResponse<AccommodationTypeGET>("Accommodation type successfully updated.", ToDto(entity));
    }

    public async Task<BaseResponse<object>> DeleteType(Guid id)
    {
        var entity = await FindType(id);

        var inUse = await _context.Accommodations.CountAsync(a => !a.IsDeleted && a.AccommodationTypeId == id);
        if (inUse > 0)
            throw new BusinessException(
                $"Type „{entity.Name}“ cannot be deleted because it is used by accommodations (total: {inUse}). " +
                "First move those accommodations to another type.");

        entity.IsDeleted = true;
        await _context.SaveChangesAsync();

        return new BaseResponse<object>("Accommodation type successfully deleted.", null);
    }

    public async Task<BaseResponse<AmenityGET>> CreateAmenity(AmenityPOST amenity)
    {
        var code = Normalize(amenity.Code, "Amenity code");
        var name = Normalize(amenity.Name, "Amenity name");
        await EnsureAmenityCodeIsFree(code, Guid.Empty);

        var entity = new Amenity
        {
            Id = Guid.NewGuid(),
            Code = code,
            Name = name,
            SortOrder = amenity.SortOrder,
            IsDeleted = false
        };

        _context.Amenities.Add(entity);
        await SaveUnique(AmenityCodeTaken(code));

        return new BaseResponse<AmenityGET>("Amenity successfully added.", ToDto(entity));
    }

    public async Task<BaseResponse<List<AmenityGET>>> GetAmenities(int page, int pageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var query = _context.Amenities.AsNoTracking().Where(a => !a.IsDeleted);
        var totalCount = await query.CountAsync();
        var items = await query
            .OrderBy(a => a.SortOrder).ThenBy(a => a.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(a => new AmenityGET { Id = a.Id, Code = a.Code, Name = a.Name, SortOrder = a.SortOrder })
            .ToListAsync();

        return new PagedResponse<AmenityGET>("Amenities successfully retrieved.", items, page, pageSize, totalCount);
    }

    public async Task<BaseResponse<AmenityGET>> GetAmenity(Guid id)
    {
        var entity = await FindAmenity(id);

        return new BaseResponse<AmenityGET>("Amenity successfully retrieved.", ToDto(entity));
    }

    public async Task<BaseResponse<AmenityGET>> UpdateAmenity(AmenityPATCH amenity)
    {
        var entity = await FindAmenity(amenity.Id);
        var code = Normalize(amenity.Code, "Amenity code");
        var name = Normalize(amenity.Name, "Amenity name");
        await EnsureAmenityCodeIsFree(code, amenity.Id);

        entity.Code = code;
        entity.Name = name;
        entity.SortOrder = amenity.SortOrder;
        await SaveUnique(AmenityCodeTaken(code));

        return new BaseResponse<AmenityGET>("Amenity successfully updated.", ToDto(entity));
    }

    public async Task<BaseResponse<object>> DeleteAmenity(Guid id)
    {
        var entity = await FindAmenity(id);

        var inUse = await _context.AccommodationDetailsAmenities.CountAsync(x => x.AmenityId == id);
        if (inUse > 0)
            throw new BusinessException(
                $"Amenity „{entity.Name}“ cannot be deleted because it is linked to accommodations (total: {inUse}). " +
                "First remove it from those accommodations.");

        entity.IsDeleted = true;
        await _context.SaveChangesAsync();

        return new BaseResponse<object>("Amenity successfully deleted.", null);
    }

    public async Task EnsureTypeExists(Guid accommodationTypeId)
    {
        if (!await _context.AccommodationTypes.AnyAsync(t => !t.IsDeleted && t.Id == accommodationTypeId))
            throw new NotFoundException($"Accommodation type with identifier {accommodationTypeId} does not exist.");
    }

    public async Task SetAmenities(Guid accommodationDetailsId, IReadOnlyCollection<Guid> amenityIds)
    {
        var wanted = amenityIds.Distinct().ToList();

        var known = await _context.Amenities
            .Where(a => !a.IsDeleted && wanted.Contains(a.Id))
            .Select(a => a.Id)
            .ToListAsync();

        var unknown = wanted.Except(known).ToList();
        if (unknown.Count > 0)
            throw new NotFoundException($"Amenity with identifier {unknown[0]} does not exist.");

        var existing = await _context.AccommodationDetailsAmenities
            .Where(x => x.AccommodationDetailsId == accommodationDetailsId)
            .ToListAsync();

        _context.AccommodationDetailsAmenities.RemoveRange(existing.Where(x => !known.Contains(x.AmenityId)));

        var alreadyLinked = existing.Select(x => x.AmenityId).ToHashSet();
        foreach (var amenityId in known.Where(id => !alreadyLinked.Contains(id)))
        {
            _context.AccommodationDetailsAmenities.Add(new AccommodationDetailsAmenity
            {
                AccommodationDetailsId = accommodationDetailsId,
                AmenityId = amenityId
            });
        }

        await _context.SaveChangesAsync();
    }

    public async Task AttachAmenities(IReadOnlyCollection<AccommodationGET> accommodations)
    {
        var withDetails = accommodations.Where(a => a.AccommodationDetails != null).ToList();
        if (withDetails.Count == 0)
            return;

        var detailIds = withDetails.Select(a => a.AccommodationDetails!.Id).Distinct().ToList();

        var rows = await _context.AccommodationDetailsAmenities
            .AsNoTracking()
            .Where(x => detailIds.Contains(x.AccommodationDetailsId) && x.Amenity != null && !x.Amenity.IsDeleted)
            .Select(x => new
            {
                x.AccommodationDetailsId,
                Amenity = new AmenityGET
                {
                    Id = x.Amenity!.Id,
                    Code = x.Amenity.Code,
                    Name = x.Amenity.Name,
                    SortOrder = x.Amenity.SortOrder
                }
            })
            .ToListAsync();

        var byDetails = rows
            .GroupBy(r => r.AccommodationDetailsId)
            .ToDictionary(g => g.Key, g => g.Select(r => r.Amenity).OrderBy(a => a.SortOrder).ToList());

        foreach (var accommodation in withDetails)
        {
            accommodation.AccommodationDetails!.Amenities =
                byDetails.TryGetValue(accommodation.AccommodationDetails.Id, out var found) ? found : new List<AmenityGET>();
        }
    }

    private async Task<AccommodationType> FindType(Guid id)
    {
        var entity = await _context.AccommodationTypes.FirstOrDefaultAsync(t => !t.IsDeleted && t.Id == id);
        if (entity == null)
            throw new NotFoundException($"Accommodation type with identifier {id} does not exist.");

        return entity;
    }

    private async Task<Amenity> FindAmenity(Guid id)
    {
        var entity = await _context.Amenities.FirstOrDefaultAsync(a => !a.IsDeleted && a.Id == id);
        if (entity == null)
            throw new NotFoundException($"Amenity with identifier {id} does not exist.");

        return entity;
    }

    private async Task EnsureTypeNameIsFree(string name, Guid exceptId)
    {
        if (await _context.AccommodationTypes.AnyAsync(t => !t.IsDeleted && t.Name == name && t.Id != exceptId))
            throw new BusinessException(TypeNameTaken(name));
    }

    private async Task EnsureAmenityCodeIsFree(string code, Guid exceptId)
    {
        if (await _context.Amenities.AnyAsync(a => !a.IsDeleted && a.Code == code && a.Id != exceptId))
            throw new BusinessException(AmenityCodeTaken(code));
    }

    /// <summary>
    /// Upisuje izmjene i prevodi kršenje jedinstvenog indeksa u poslovnu grešku. Provjere iznad
    /// hvataju duplikat prije upisa, ali između njihovog upita i <c>SaveChangesAsync</c> drugi
    /// zahtjev može upisati isti naziv; bez ovoga bi taj slučaj završio kao 500.
    /// </summary>
    private async Task SaveUnique(string duplicateMessage)
    {
        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateException ex)
            when (ex.InnerException is SqlException sql && (sql.Number == DuplicateKeyRow || sql.Number == DuplicateKeyIndex))
        {
            throw new BusinessException(duplicateMessage);
        }
    }

    private static string TypeNameTaken(string name) =>
        $"Accommodation type named „{name}“ already exists.";

    private static string AmenityCodeTaken(string code) =>
        $"Amenity with code „{code}“ already exists.";

    private static string Normalize(string value, string label)
    {
        var trimmed = value?.Trim() ?? string.Empty;
        if (trimmed.Length < MinTextLength)
            throw new BusinessException($"{label} is required and must have at least {MinTextLength} characters.");

        return trimmed;
    }

    private static AccommodationTypeGET ToDto(AccommodationType entity) =>
        new() { Id = entity.Id, Name = entity.Name, SortOrder = entity.SortOrder };

    private static AmenityGET ToDto(Amenity entity) =>
        new() { Id = entity.Id, Code = entity.Code, Name = entity.Name, SortOrder = entity.SortOrder };
}
