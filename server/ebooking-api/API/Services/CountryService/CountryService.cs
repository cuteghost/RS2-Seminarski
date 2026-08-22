using Models.DTO.CountryDTO;
using AutoMapper;
using API.Exceptions;
using Models.Domain;
using Repository.Interfaces;
using Microsoft.EntityFrameworkCore;
namespace Services.CountryService;

public class CountryService : ICountryService
{
    private const int MaxPageSize = 100;
    private const int DefaultPageSize = 10;

    private readonly IGenericRepository<Country> _countryRepository;
    private readonly IGenericRepository<City> _cityRepository;
    private readonly IMapper _mapper;

    public CountryService(IGenericRepository<Country> countryRepository, IGenericRepository<City> cityRepository, IMapper mapper)
    {
        _countryRepository = countryRepository;
        _cityRepository = cityRepository;
        _mapper = mapper;
    }

    public async Task<BaseResponse<CountryGET>> CreateCountry(CountryPOST country)
    {
        BaseResponse<CountryGET> toReturn;
        try
        {
            var forRepo = _mapper.Map<Country>(country);
            forRepo.Id = Guid.NewGuid();

            var success = await _countryRepository.Add(forRepo);

            var mapped = _mapper.Map<CountryGET>(forRepo);
            toReturn = new BaseResponse<CountryGET>("Country created successfully", mapped);
        }
        catch (DbUpdateException ex) when (ex.InnerException is Microsoft.Data.SqlClient.SqlException sqlEx && (sqlEx.Number == 2627 || sqlEx.Number == 2601)) // Unique constraint violation
        {
            throw new BusinessException("Error creating country. Country already exists");
        }
        return toReturn;
    }

    public async Task<BaseResponse<List<CountryGET>>> GetCountries(int page, int pageSize)
    {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = DefaultPageSize;
        if (pageSize > MaxPageSize) pageSize = MaxPageSize;

        var (items, totalCount) = await _countryRepository.GetPaged(page, pageSize);
        var mapped = _mapper.Map<List<CountryGET>>(items);

        return new PagedResponse<CountryGET>("Countries fetched successfully", mapped, page, pageSize, totalCount);
    }

    public async Task<BaseResponse<CountryGET>> GetCountry(Guid countryId)
    {
        var getFromRepo = await _countryRepository.Get(c => c.Id == countryId);

        if (getFromRepo == null)
            throw new NotFoundException("Country with the provided ID doesn't exist");

        var mapped = _mapper.Map<CountryGET>(getFromRepo);
        return new BaseResponse<CountryGET>("Country fetched successfully", mapped);
    }

    public async Task<BaseResponse<CountryGET>> UpdateCountry(CountryPATCH country)
    {
        var existing = await _countryRepository.Get(c => c.Id == country.Id);
        if (existing == null)
            throw new NotFoundException("Country with the provided ID doesn't exist");

        var forRepo = _mapper.Map<Country>(country);

        try
        {
            await _countryRepository.Update(c => c.Id == country.Id, forRepo);
        }
        catch (DbUpdateException ex) when (ex.InnerException is Microsoft.Data.SqlClient.SqlException sqlEx && (sqlEx.Number == 2627 || sqlEx.Number == 2601)) // Unique constraint violation
        {
            throw new BusinessException("Error updating country. Another country with this name already exists");
        }

        var mapped = _mapper.Map<CountryGET>(forRepo);
        return new BaseResponse<CountryGET>("Country updated successfully", mapped);
    }

    public async Task<BaseResponse<CountryGET>> DeleteCountry(Guid countryId)
    {
        var existing = await _countryRepository.Get(c => c.Id == countryId);
        if (existing == null)
            throw new NotFoundException("Country with the provided ID doesn't exist");

        var citiesUsingCountry = await _cityRepository.GetAll(c => c.CountryId == countryId);
        if (citiesUsingCountry.Any())
            throw new BusinessException("Cannot delete this country because cities are still assigned to it");

        await _countryRepository.Delete(c => c.Id == countryId);

        var mapped = _mapper.Map<CountryGET>(existing);
        return new BaseResponse<CountryGET>("Country deleted successfully", mapped);
    }
}
