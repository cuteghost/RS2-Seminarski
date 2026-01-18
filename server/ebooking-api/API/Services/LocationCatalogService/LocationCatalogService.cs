using API.Exceptions;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Models.Constants;
using Models.Domain;
using Models.DTO.LocationDTO;
using Repository.Interfaces;
using Services.CurrentUserService;

namespace Services.LocationCatalogService;

/// <inheritdoc cref="ILocationCatalogService"/>
public class LocationCatalogService : ILocationCatalogService
{
    // Accommodation nema deklarisano svojstvo za strani ključ prema lokaciji, nego samo
    // navigaciju, pa EF drži ključ kao sjenovito svojstvo pod ovim imenom.
    private const string AccommodationLocationForeignKey = "LocationId";
    private const int AddressMinLength = 5;
    private const int AddressMaxLength = 50;

    private readonly IGenericRepository<Location> _locationRepository;
    private readonly IGenericRepository<City> _cityRepository;
    private readonly IGenericRepository<Accommodation> _accommodationRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly IMapper _mapper;

    public LocationCatalogService(IGenericRepository<Location> locationRepository,
                                  IGenericRepository<City> cityRepository,
                                  IGenericRepository<Accommodation> accommodationRepository,
                                  ICurrentUserService currentUser,
                                  IMapper mapper)
    {
        _locationRepository = locationRepository;
        _cityRepository = cityRepository;
        _accommodationRepository = accommodationRepository;
        _currentUser = currentUser;
        _mapper = mapper;
    }

    public async Task<BaseResponse<LocationGET>> CreateLocation(LocationPOST location)
    {
        var address = Normalize(location.Address);
        EnsureCoordinatesAreValid(location.Latitude, location.Longitude);
        await EnsureCityExists(location.CityId);

        var forRepo = _mapper.Map<Location>(location);
        // Id se ranije nikad nije postavljao, a Add se pozivao bez await — lokacija se upisivala
        // naknadno, a odgovor je nosio prazan Guid.
        forRepo.Id = Guid.NewGuid();
        forRepo.Address = address;
        forRepo.CityId = location.CityId;

        await _locationRepository.Add(forRepo);

        return new BaseResponse<LocationGET>("Location created successfully.", await Read(forRepo.Id));
    }

    public async Task<BaseResponse<List<LocationGET>>> GetLocations(int page, int pageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var (items, totalCount) = await _locationRepository.GetPaged(page, pageSize, false, l => l.City, l => l.City.Country);
        var mapped = _mapper.Map<List<LocationGET>>(items);
        await AttachAccommodationCounts(mapped);

        return new PagedResponse<LocationGET>("Locations retrieved successfully.", mapped, page, pageSize, totalCount);
    }

    public async Task<BaseResponse<LocationGET>> GetLocation(Guid locationId)
    {
        return new BaseResponse<LocationGET>("Location retrieved successfully.", await Read(locationId));
    }

    public async Task<BaseResponse<LocationGET>> UpdateLocation(LocationPATCH location)
    {
        var existing = await _locationRepository.Get(l => l.Id == location.Id);
        if (existing == null)
            throw new NotFoundException($"Location with identifier {location.Id} does not exist.");

        var address = Normalize(location.Address);
        EnsureCoordinatesAreValid(location.Latitude, location.Longitude);
        await EnsureCityExists(location.CityId);
        await EnsureCallerMayEdit(location.Id);

        var forRepo = _mapper.Map<Location>(location);
        forRepo.Address = address;
        forRepo.CityId = location.CityId;

        if (!await _locationRepository.Update(l => l.Id == location.Id, forRepo))
            throw new NotFoundException($"Location with identifier {location.Id} does not exist.");

        return new BaseResponse<LocationGET>("Location updated successfully.", await Read(location.Id));
    }

    public async Task<BaseResponse<object>> DeleteLocation(Guid locationId)
    {
        var existing = await _locationRepository.Get(l => l.Id == locationId);
        if (existing == null)
            throw new NotFoundException($"Location with identifier {locationId} does not exist.");

        var accommodationsHere = await _accommodationRepository.Count(
            a => EF.Property<Guid?>(a, AccommodationLocationForeignKey) == locationId);
        if (accommodationsHere > 0)
            throw new BusinessException(
                $"Location \"{existing.Address}\" cannot be deleted because it has accommodations (total: {accommodationsHere}). " +
                "First delete those accommodations or move them to another location.");

        await _locationRepository.Delete(l => l.Id == locationId);

        return new BaseResponse<object>("Location deleted successfully.", null);
    }

    private async Task<LocationGET> Read(Guid locationId)
    {
        var location = await _locationRepository.Get(l => l.Id == locationId, false, l => l.City, l => l.City.Country);
        if (location == null)
            throw new NotFoundException($"Location with identifier {locationId} does not exist.");

        var mapped = _mapper.Map<LocationGET>(location);
        await AttachAccommodationCounts(new List<LocationGET> { mapped });

        return mapped;
    }

    private async Task AttachAccommodationCounts(IReadOnlyCollection<LocationGET> locations)
    {
        if (locations.Count == 0)
            return;

        var locationIds = locations.Select(l => l.Id).ToList();

        var rows = await _accommodationRepository.Project(
            a => locationIds.Contains(EF.Property<Guid>(a, AccommodationLocationForeignKey)),
            a => EF.Property<Guid>(a, AccommodationLocationForeignKey));

        var byLocation = rows.GroupBy(id => id).ToDictionary(g => g.Key, g => g.Count());

        foreach (var location in locations)
            location.AccommodationCount = byLocation.TryGetValue(location.Id, out var count) ? count : 0;
    }

    private async Task EnsureCityExists(Guid cityId)
    {
        var city = await _cityRepository.Get(c => c.Id == cityId);
        if (city == null)
            throw new NotFoundException($"City with identifier {cityId} does not exist.");
    }

    private async Task EnsureCallerMayEdit(Guid locationId)
    {
        if (_currentUser.Role == Roles.Administrator)
            return;

        var partnerId = await _currentUser.GetPartnerIdAsync();
        var ownsAccommodationHere = partnerId != Guid.Empty && await _accommodationRepository.Any(
            a => a.OwnerId == partnerId && EF.Property<Guid?>(a, AccommodationLocationForeignKey) == locationId);

        if (!ownsAccommodationHere)
            throw new BusinessException(
                "A location can only be edited by an administrator or by the partner whose accommodation is at that location.");
    }

    private static void EnsureCoordinatesAreValid(double latitude, double longitude)
    {
        if (latitude < -90 || latitude > 90)
            throw new BusinessException("Latitude must be between -90 and 90.");

        if (longitude < -180 || longitude > 180)
            throw new BusinessException("Longitude must be between -180 and 180.");
    }

    private static string Normalize(string address)
    {
        var trimmed = address?.Trim() ?? string.Empty;
        if (trimmed.Length < AddressMinLength || trimmed.Length > AddressMaxLength)
            throw new BusinessException(
                $"Address is required and must be between {AddressMinLength} and {AddressMaxLength} characters long.");

        return trimmed;
    }
}
