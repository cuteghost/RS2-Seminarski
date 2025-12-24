using Models.Domain;
using Models.DTO.ReviewDTO;

namespace Profiles;

public class ReviewProfile : AutoMapper.Profile
{

    public ReviewProfile()
    {
        CreateMap<Review, ReviewPOST>().ReverseMap();
    }
}
