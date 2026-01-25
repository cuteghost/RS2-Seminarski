using Models.DTO.AccommodationDetailsDTO;
using Models.Domain;

namespace Profiles;

public class AccommodationDetailsProfiles : AutoMapper.Profile
{
    public AccommodationDetailsProfiles()
    {
        CreateMap<AccommodationDetails, AccommodationDetailsGET>()
            .ForMember(dest => dest.Amenities, opt => opt.Ignore());

        CreateMap<AccommodationDetailsPOST, AccommodationDetails>()
            .ForMember(dest => dest.AccommodationDetailsAmenities, opt => opt.Ignore());

        CreateMap<AccommodationDetailsPATCH, AccommodationDetails>()
            .ForMember(dest => dest.AccommodationDetailsAmenities, opt => opt.Ignore());
    }
}
