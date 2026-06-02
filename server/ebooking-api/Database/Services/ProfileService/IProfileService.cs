using Models.Domain;
using Models.DTO.UserDTO;
using Models.DTO.UserDTO.Partner;

namespace Database.Services.ProfileService;

public interface IProfileService
{
    Task<User> UpdateUserProfile(Guid userId, UserPATCH profile);

    Task<User> UpdateUserByAdministrator(Guid actorUserId, Guid targetUserId, ManagedUserPATCH changes);

    Task<Partner> UpdatePartnerProfile(Guid userId, Guid partnerId, PartnerPATCH profile);
}
