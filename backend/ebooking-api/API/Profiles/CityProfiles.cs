using Models.DTO.CityDTO;
using Models.Domain;

namespace Profiles.CityProfile;
public class CityProfiles : AutoMapper.Profile
{
    public CityProfiles()
    {
        CreateMap<City, CityGET>().ReverseMap();
        CreateMap<City, CityPOST>().ReverseMap();
        CreateMap<City, CityPATCH>().ReverseMap();
    }
}