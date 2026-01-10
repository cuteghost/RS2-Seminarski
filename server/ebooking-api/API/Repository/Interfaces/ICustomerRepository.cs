using Models.Domain;

namespace Repository.Interfaces;

public interface ICustomerRepository
{
    public Task<bool> AddCustomer(User user, Customer customer);
    public Task<Customer> GetCustomerDetails(Guid id);
    public Task<Customer> GetCustomerByEmail(string email);
}
