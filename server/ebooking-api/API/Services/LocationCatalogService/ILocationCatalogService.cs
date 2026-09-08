using Models.Domain;
using Models.DTO.LocationDTO;

namespace Services.LocationCatalogService;

/// <summary>
/// Pun CRUD nad lokacijama.
///
/// <para>
/// Ime nije <c>ILocationService</c> jer to ime već nosi servis za geografiju
/// (<see cref="Services.LocationService.ILocationService"/>): on računa udaljenost i gradi
/// uslov za pretragu po poluprečniku, registrovan je kao <c>Singleton</c> i ne dira bazu.
/// Ovaj servis radi upravo suprotno — čita i mijenja zapise — pa je <c>Scoped</c> i odvojen.
/// </para>
/// </summary>
public interface ILocationCatalogService
{
    Task<BaseResponse<LocationGET>> CreateLocation(LocationPOST location);

    Task<BaseResponse<List<LocationGET>>> GetLocations(int page, int pageSize);

    Task<BaseResponse<LocationGET>> GetLocation(Guid locationId);

    /// <summary>
    /// Izmjenu radi administrator ili partner čiji smještaj stoji na toj lokaciji —
    /// <c>AccommodationPATCH</c> ne nosi lokaciju, pa partner inače nema načina ispraviti adresu.
    /// </summary>
    Task<BaseResponse<LocationGET>> UpdateLocation(LocationPATCH location);

    /// <summary>
    /// Meko brisanje. Odbija se ako na lokaciji stoji ijedan smještaj.
    /// </summary>
    Task<BaseResponse<object>> DeleteLocation(Guid locationId);
}
