using Models.Domain;
using Models.DTO.CityDTO;

namespace Services.CityService;

/// <summary>
/// Pun CRUD nad gradovima. Pravila brisanja i provjere jedinstvenosti su poslovna logika, pa
/// stoje ovdje, a ne u kontroleru — isti raspored kao kod <c>ICountryService</c>.
/// </summary>
public interface ICityService
{
    Task<BaseResponse<CityGET>> CreateCity(CityPOST city);

    Task<BaseResponse<List<CityGET>>> GetCities(int page, int pageSize);

    Task<BaseResponse<List<CityGET>>> GetCitiesByCountry(Guid countryId, int page, int pageSize);

    Task<BaseResponse<CityGET>> GetCity(Guid cityId);

    Task<BaseResponse<CityGET>> UpdateCity(CityPATCH city);

    /// <summary>
    /// Meko brisanje. Odbija se ako je grad u upotrebi — ako na njemu stoji ijedna lokacija.
    /// </summary>
    Task<BaseResponse<object>> DeleteCity(Guid cityId);
}
