using Models.DTO.CountryDTO;
using AutoMapper;
using API.Exceptions;
using Models.Domain;
using Repository.Interfaces;
using Microsoft.EntityFrameworkCore;
namespace Services.CountryService;

public class CountryService: ICountryService
{
    private readonly IGenericRepository<Country> _countryRepository;
    private readonly IMapper _mapper;

    public CountryService(IGenericRepository<Country> countryRepository, IMapper mapper)
    {
        _countryRepository = countryRepository;
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

            var forBase = _mapper.Map<CountryGET>(forRepo);
            toReturn = new BaseResponse<CountryGET>("Country created successfully", forBase);
        }
        catch (DbUpdateException ex) when (ex.InnerException is Microsoft.Data.SqlClient.SqlException sqlEx && (sqlEx.Number == 2627 || sqlEx.Number == 2601)) // Unique constraint violation
        {
            throw new BusinessException("Error creating country. Country already exists");
        }
        return toReturn;
    }
    public Task<BaseResponse<List<CountryGET>>> GetCountries(int page, int pageSize)
    {
        return null;  
    }
    public Task<BaseResponse<CountryGET>> GetCountry(Guid countryId)
    {
        return null;

    }
    public Task<BaseResponse<CountryGET>> DeleteCountry(Guid countryId)
    {
        return null;

    }
    public Task<BaseResponse<CountryGET>> UpdateCountry(CountryPATCH country)
    {
        return null;

    }

}