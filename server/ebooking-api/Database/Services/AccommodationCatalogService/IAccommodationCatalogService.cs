using Models.Domain;
using Models.DTO.AccommodationDTO;
using Models.DTO.AccommodationTypeDTO;
using Models.DTO.AmenityDTO;

namespace Database.Services.AccommodationCatalogService;

public interface IAccommodationCatalogService
{
    Task<BaseResponse<AccommodationTypeGET>> CreateType(AccommodationTypePOST type);

    Task<BaseResponse<List<AccommodationTypeGET>>> GetTypes(int page, int pageSize);

    Task<BaseResponse<AccommodationTypeGET>> GetType(Guid id);

    Task<BaseResponse<AccommodationTypeGET>> UpdateType(AccommodationTypePATCH type);

    Task<BaseResponse<object>> DeleteType(Guid id);

    Task<BaseResponse<AmenityGET>> CreateAmenity(AmenityPOST amenity);

    Task<BaseResponse<List<AmenityGET>>> GetAmenities(int page, int pageSize);

    Task<BaseResponse<AmenityGET>> GetAmenity(Guid id);

    Task<BaseResponse<AmenityGET>> UpdateAmenity(AmenityPATCH amenity);

    Task<BaseResponse<object>> DeleteAmenity(Guid id);

    Task EnsureTypeExists(Guid accommodationTypeId);

    Task SetAmenities(Guid accommodationDetailsId, IReadOnlyCollection<Guid> amenityIds);

    Task AttachAmenities(IReadOnlyCollection<AccommodationGET> accommodations);
}
