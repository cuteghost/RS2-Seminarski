using Models.Domain;
using Models.DTO.MessengerDTO;

namespace Profiles.CityProfile;
public class MessageProfiles : AutoMapper.Profile
{
    public MessageProfiles()
    {
        CreateMap<Message, MessagePOST>().ReverseMap();
        CreateMap<Message, MessageGET>().ReverseMap();
        CreateMap<Chat, ChatPOST>().ReverseMap();
        CreateMap<Chat, ChatGET>().ReverseMap();
    }
}