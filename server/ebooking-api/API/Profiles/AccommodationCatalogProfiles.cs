using Models.Domain;
using Models.DTO.AccommodationTypeDTO;
using Models.DTO.AmenityDTO;

namespace Profiles;

public class AccommodationCatalogProfiles : AutoMapper.Profile
{
    public AccommodationCatalogProfiles()
    {
        CreateMap<AccommodationType, AccommodationTypeGET>().ReverseMap();
        CreateMap<Amenity, AmenityGET>().ReverseMap();
    }
}
