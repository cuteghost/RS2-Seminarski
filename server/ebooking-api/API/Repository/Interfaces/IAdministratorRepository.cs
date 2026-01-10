
using Models.Domain;

namespace Repository.Interfaces;

public interface IAdministratorRepository
{
    public Task<Administrator> GetAdminDetails(Guid id);

    /// <summary>Kreira korisnika i administratorski zapis u jednom <c>SaveChangesAsync</c> pozivu.</summary>
    public Task<Administrator> AddAdministrator(User user, Guid creatorId);

    public Task<Administrator> UpdateAdministrator(Guid administratorId, User changes);
}
