using Models.DTO.AccommodationDTO;
using Models.Domain;

namespace Profiles;

public class AccommodationProfiles : AutoMapper.Profile
{
    public AccommodationProfiles()
    {
        CreateMap<Accommodation, AccommodationGET>()
            .ForMember(dest => dest.AccommodationTypeName,
                opt => opt.MapFrom(src => src.AccommodationType != null ? src.AccommodationType.Name : string.Empty));

        CreateMap<Accommodation, RecommendedAccommodationGET>()
            .IncludeBase<Accommodation, AccommodationGET>()
            .ForMember(dest => dest.Reason, opt => opt.Ignore())
            .ForMember(dest => dest.Reasons, opt => opt.Ignore())
            .ForMember(dest => dest.RecommendationScore, opt => opt.Ignore());

        CreateMap<AccommodationPOST, Accommodation>()
            .ForMember(dest => dest.AccommodationType, opt => opt.Ignore())
            .ForMember(dest => dest.Reservations, opt => opt.Ignore());

        CreateMap<AccommodationPATCH, Accommodation>()
            .ForMember(dest => dest.AccommodationType, opt => opt.Ignore())
            .ForMember(dest => dest.Location, opt => opt.Ignore())
            .ForMember(dest => dest.Reservations, opt => opt.Ignore())
            .ForMember(dest => dest.Status, opt => opt.Ignore());
    }
}
