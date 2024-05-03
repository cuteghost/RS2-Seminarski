using Models.Domain;

namespace Repository.Interfaces;

public interface ICustomerRepository
{
    public Task<bool> AddCustomer(User user, Customer customer);
    public Task<Customer> GetCustomerDetails(Guid id, string JWT);
    public Task<bool> UpdateCustomer(Customer customer);
    public Task<Customer> GetCustomerById(Guid id);
    public Task<Customer> GetCustomerByEmail(string email);
    public Task<bool> Delete(Guid id, string Authorization);
}
