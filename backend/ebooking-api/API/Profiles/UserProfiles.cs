using Models.Domain;
using Models.DTO.AuthDTO;
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

        CreateMap<PartnerPOST, User>().ReverseMap();
        CreateMap<PartnerPATCH, User>().ReverseMap();


        CreateMap<Administrator, AdministratorGET>().ReverseMap();
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
}