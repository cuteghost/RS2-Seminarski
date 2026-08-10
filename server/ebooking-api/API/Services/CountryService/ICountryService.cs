using Models.DTO.CountryDTO;
using Models.Domain;

namespace Services.CountryService;

public interface   ICountryService
{
    Task<BaseResponse<CountryGET>> CreateCountry(CountryPOST country);
    Task<BaseResponse<List<CountryGET>>> GetCountries(int page, int pageSize);
    Task<BaseResponse<CountryGET>> GetCountry(Guid countryId);
    Task<BaseResponse<CountryGET>> DeleteCountry(Guid countryId);
    Task<BaseResponse<CountryGET>> UpdateCountry(CountryPATCH country);

}