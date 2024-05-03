
using Models.Domain;

namespace Repository.Interfaces;

public interface IAdministratorRepository
{
    public Task<IEnumerable<Customer>> GetAllCustomers();
    Task<object?> GetAllPartners();
}

