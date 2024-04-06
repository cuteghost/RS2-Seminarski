using Models.DTO.AccommodationDTO;
using Models.Domain;

namespace Profiles;

public class AccommodationProfiles : AutoMapper.Profile
{
    public AccommodationProfiles()
    {
        CreateMap<Accommodation, AccommodationGET>().ReverseMap();
        CreateMap<Accommodation, AccommodationPOST>().ReverseMap();
        CreateMap<Accommodation, AccommodationPATCH>().ReverseMap();
    }
        
}
