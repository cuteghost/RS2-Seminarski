using Models.Domain;
using Models.DTO.MessengerDTO;

namespace Messenger.Profiles;

public class MessageProfiles : AutoMapper.Profile
{
    public MessageProfiles()
    {
        CreateMap<Message, MessageGET>()
            .ForMember(dest => dest.TimeStamp, opt => opt.MapFrom(src => src.Timestamp))
            .ForMember(dest => dest.isCurrent, opt => opt.Ignore());
    }
}
