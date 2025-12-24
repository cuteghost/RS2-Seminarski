using Models.DTO.AccommodationImages;
using Models.Domain;

namespace Profiles;

public class AccommodationImagesProfiles : AutoMapper.Profile
{
    public AccommodationImagesProfiles()
    {
        CreateMap<AccommodationImages, AccommodationImagesGET>().ReverseMap();
        CreateMap<AccommodationImages, AccommodationImagesPOST>().ReverseMap();
        CreateMap<AccommodationImages, AccommodationImagesPATCH>().ReverseMap();
    }

}
