using API.Models.DTO.AccommodationDetailsDTO;
using Models.Domain;

namespace Profiles;

public class AccommodationDetailsProfiles : AutoMapper.Profile
{
    public AccommodationDetailsProfiles()
    {
        CreateMap<AccommodationDetails, AccommodationDetailsGET>().ReverseMap();
        CreateMap<AccommodationDetails, AccommodationDetailsPOST>().ReverseMap();
        CreateMap<AccommodationDetails, AccommodationDetailsPATCH>().ReverseMap();
    }
        
}
