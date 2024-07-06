using Models.Domain;
using Models.DTO.ReservationDTO;

namespace Profiles;

public class ReservationProfile : AutoMapper.Profile
{

    public ReservationProfile()
    {
        CreateMap<Reservation, ReservationGET>().ReverseMap();
        CreateMap<Reservation, ReservationPOST>().ReverseMap();
        CreateMap<Reservation, ReservationPATCH>().ReverseMap();
    }


}
