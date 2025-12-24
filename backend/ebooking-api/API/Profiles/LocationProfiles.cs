using Models.Domain;
using Models.DTO.LocationDTO;

namespace Profiles.LocationProfile;
public class LocationProfiles : AutoMapper.Profile
{
    public LocationProfiles()
    {
        CreateMap<Location, LocationGET>().ForMember(
            dest => dest.CountryName,
            opt => opt.MapFrom(src => src.City  != null && src.City.Country != null ? src.City.Country.Name : string.Empty)
        ).ReverseMap();
        CreateMap<Location, LocationPOST>().ReverseMap();
        CreateMap<Location, LocationPatch>().ReverseMap();
    }
}