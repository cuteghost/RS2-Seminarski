using Models.Domain;
using Models.DTO.CountryDTO;

namespace Profiles.CountryProfile;
public class CountryProfiles : AutoMapper.Profile
{
    public CountryProfiles()
    {
        CreateMap<Country, CountryGET>().ReverseMap();
        CreateMap<Country, CountryPOST>().ReverseMap();
        CreateMap<Country, CountryPATCH>().ReverseMap();
    }
}