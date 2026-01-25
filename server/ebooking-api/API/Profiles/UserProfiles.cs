using Models.Domain;
using Models.DTO.AuthDTO;
using Models.DTO.UserDTO;
using Models.DTO.UserDTO.Administrator;
using Models.DTO.UserDTO.Customer;
using Models.DTO.UserDTO.Partner;


namespace Profiles.UserProfile;

public class UserProfiles : AutoMapper.Profile
{
    public UserProfiles()
    {

        CreateMap<AdministratorPOST, User>().ReverseMap();
        CreateMap<AdministratorPATCH, User>().ReverseMap();

        CreateMap<CustomerGET, User>().ReverseMap();
        CreateMap<CustomerPOST, User>().ReverseMap();
        CreateMap<CustomerPATCH, User>().ReverseMap();

        CreateMap<ProfileDTO, User>().ReverseMap();

        CreateMap<User, UserGET>()
            .ForMember(dest => dest.UserId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.UserDisplayName, opt => opt.MapFrom(src => src.DisplayName))
            .ForMember(dest => dest.UserFirstName, opt => opt.MapFrom(src => src.FirstName))
            .ForMember(dest => dest.UserLastName, opt => opt.MapFrom(src => src.LastName))
            .ForMember(dest => dest.UserBirthDate, opt => opt.MapFrom(src => src.BirthDate))
            .ForMember(dest => dest.UserGender, opt => opt.MapFrom(src => src.Gender))
            .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.Email))
            .ForMember(dest => dest.UserSocialLink, opt => opt.MapFrom(src => src.SocialLink))
            .ForMember(dest => dest.UserSocialProvider, opt => opt.MapFrom(src => src.SocialProvider))
            .ForMember(dest => dest.UserIsActive, opt => opt.MapFrom(src => src.IsActive))
            .ForMember(dest => dest.UserImage, opt => opt.MapFrom(src => src.Image));

        CreateMap<PartnerPOST, User>().ReverseMap();
        CreateMap<PartnerPATCH, User>().ReverseMap();

        CreateMap<User, UserListItemGET>()
            .ForMember(dest => dest.UserId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.UserDisplayName, opt => opt.MapFrom(src => src.DisplayName))
            .ForMember(dest => dest.UserFirstName, opt => opt.MapFrom(src => src.FirstName))
            .ForMember(dest => dest.UserLastName, opt => opt.MapFrom(src => src.LastName))
            .ForMember(dest => dest.UserBirthDate, opt => opt.MapFrom(src => src.BirthDate))
            .ForMember(dest => dest.UserGender, opt => opt.MapFrom(src => src.Gender))
            .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.Email))
            .ForMember(dest => dest.UserSocialLink, opt => opt.MapFrom(src => src.SocialLink))
            .ForMember(dest => dest.UserSocialProvider, opt => opt.MapFrom(src => src.SocialProvider))
            .ForMember(dest => dest.UserIsActive, opt => opt.MapFrom(src => src.IsActive))
            .ForMember(dest => dest.Role, opt => opt.MapFrom(src => ToRole(src.Role)));


        CreateMap<Administrator, AdministratorGET>()
            .ForMember(dest => dest.Role, opt => opt.MapFrom(src => Models.DTO.UserDTO.Role.Administrator))
            .ReverseMap();
        CreateMap<Administrator, AdministratorPOST>().ReverseMap();
        CreateMap<Administrator, AdministratorPATCH>().ReverseMap();

        CreateMap<Customer, CustomerGET>().ReverseMap();
        CreateMap<Customer, CustomerPOST>().ReverseMap();
        CreateMap<Customer, CustomerPATCH>().ReverseMap();

        CreateMap<Partner, PartnerGET>().ReverseMap();
        CreateMap<Partner, PartnerPOST>().ReverseMap();
        CreateMap<Partner, PartnerPATCH>().ReverseMap();

        CreateMap<User, LoginDTO>().ReverseMap();

    }

    private static Models.DTO.UserDTO.Role ToRole(Models.Domain.Role role) => role switch
    {
        Models.Domain.Role.AdministratorRole => Models.DTO.UserDTO.Role.Administrator,
        Models.Domain.Role.PartnerRole => Models.DTO.UserDTO.Role.Partner,
        _ => Models.DTO.UserDTO.Role.Customer,
    };
}