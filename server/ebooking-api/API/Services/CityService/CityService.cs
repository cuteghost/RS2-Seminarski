using API.Exceptions;
using AutoMapper;
using Models.Constants;
using Models.Domain;
using Models.DTO.CityDTO;
using Repository.Interfaces;

namespace Services.CityService;

/// <inheritdoc cref="ICityService"/>
public class CityService : ICityService
{
    private readonly IGenericRepository<City> _cityRepository;
    private readonly IGenericRepository<Country> _countryRepository;
    private readonly IGenericRepository<Location> _locationRepository;
    private readonly IMapper _mapper;

    public CityService(IGenericRepository<City> cityRepository,
                       IGenericRepository<Country> countryRepository,
                       IGenericRepository<Location> locationRepository,
                       IMapper mapper)
    {
        _cityRepository = cityRepository;
        _countryRepository = countryRepository;
        _locationRepository = locationRepository;
        _mapper = mapper;
    }

    public async Task<BaseResponse<CityGET>> CreateCity(CityPOST city)
    {
        var name = Normalize(city.Name);
        await EnsureCountryExists(city.CountryId);
        await EnsureNameIsFree(name, city.CountryId, Guid.Empty);

        var forRepo = _mapper.Map<City>(city);
        forRepo.Id = Guid.NewGuid();
        forRepo.Name = name;
        // Postavlja se samo strani ključ. Repozitorij vraća entitete sa AsNoTracking, pa bi
        // dodjela navigacije natjerala EF da pokuša ponovo upisati i državu.
        forRepo.CountryId = city.CountryId;

        await _cityRepository.Add(forRepo);

        return new BaseResponse<CityGET>("City added successfully.", await Read(forRepo.Id));
    }

    public async Task<BaseResponse<List<CityGET>>> GetCities(int page, int pageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var (items, totalCount) = await _cityRepository.GetPaged(page, pageSize, false, c => c.Country);
        var mapped = _mapper.Map<List<CityGET>>(items);

        return new PagedResponse<CityGET>("Cities retrieved successfully.", mapped, page, pageSize, totalCount);
    }

    public async Task<BaseResponse<List<CityGET>>> GetCitiesByCountry(Guid countryId, int page, int pageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var (items, totalCount) = await _cityRepository.GetPaged(c => c.CountryId == countryId, page, pageSize, false, c => c.Country);
        var mapped = _mapper.Map<List<CityGET>>(items);

        return new PagedResponse<CityGET>("Cities in the country retrieved successfully.", mapped, page, pageSize, totalCount);
    }

    public async Task<BaseResponse<CityGET>> GetCity(Guid cityId)
    {
        return new BaseResponse<CityGET>("City retrieved successfully.", await Read(cityId));
    }

    public async Task<BaseResponse<CityGET>> UpdateCity(CityPATCH city)
    {
        var existing = await _cityRepository.Get(c => c.Id == city.Id);
        if (existing == null)
            throw new NotFoundException($"City with identifier {city.Id} does not exist.");

        var name = Normalize(city.Name);
        await EnsureCountryExists(city.CountryId);
        await EnsureNameIsFree(name, city.CountryId, city.Id);

        var forRepo = _mapper.Map<City>(city);
        forRepo.Name = name;
        forRepo.CountryId = city.CountryId;

        if (!await _cityRepository.Update(c => c.Id == city.Id, forRepo))
            throw new NotFoundException($"City with identifier {city.Id} does not exist.");

        return new BaseResponse<CityGET>("City updated successfully.", await Read(city.Id));
    }

    public async Task<BaseResponse<object>> DeleteCity(Guid cityId)
    {
        var existing = await _cityRepository.Get(c => c.Id == cityId);
        if (existing == null)
            throw new NotFoundException($"City with identifier {cityId} does not exist.");

        // Broji se u SQL-u (COUNT), bez učitavanja lokacija.
        var locationsInCity = await _locationRepository.Count(l => l.CityId == cityId);
        if (locationsInCity > 0)
            throw new BusinessException(
                $"City \"{existing.Name}\" cannot be deleted because it has locations (total: {locationsInCity}). " +
                "First delete or move those locations.");

        await _cityRepository.Delete(c => c.Id == cityId);

        return new BaseResponse<object>("City deleted successfully.", null);
    }

    private async Task<CityGET> Read(Guid cityId)
    {
        var city = await _cityRepository.Get(c => c.Id == cityId, false, c => c.Country);
        if (city == null)
            throw new NotFoundException($"City with identifier {cityId} does not exist.");

        return _mapper.Map<CityGET>(city);
    }

    private async Task EnsureCountryExists(Guid countryId)
    {
        var country = await _countryRepository.Get(c => c.Id == countryId);
        if (country == null)
            throw new NotFoundException($"Country with identifier {countryId} does not exist.");
    }

    /// <summary>
    /// Dva grada istog imena u istoj državi su duplikat. Poređenje je u SQL-u i po
    /// podrazumijevanoj kolaciji baze ne razlikuje velika i mala slova.
    /// </summary>
    private async Task EnsureNameIsFree(string name, Guid countryId, Guid exceptCityId)
    {
        if (await _cityRepository.Any(c => c.CountryId == countryId && c.Name == name && c.Id != exceptCityId))
            throw new BusinessException($"A city named \"{name}\" already exists in that country.");
    }

    private static string Normalize(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new BusinessException("City name is required and must be at least two characters long.");

        return name.Trim();
    }
}
