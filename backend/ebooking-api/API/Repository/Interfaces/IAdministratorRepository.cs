
using Models.Domain;

namespace Repository.Interfaces;

public interface IAdministratorRepository
{
    public Task<IEnumerable<Customer>> GetAllCustomers();
    public Task<object?> GetAllPartners();
    public Task<Administrator> GetAdminDetails(Guid id, string JWT);

}

