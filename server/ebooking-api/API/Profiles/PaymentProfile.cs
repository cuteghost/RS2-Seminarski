using Models.Domain;
using Models.DTO.PaymentDTO;

namespace Profiles;

public class PaymentProfile : AutoMapper.Profile
{
    public PaymentProfile()
    {
        CreateMap<Payment, PaymentGET>().ReverseMap();
    }
}
