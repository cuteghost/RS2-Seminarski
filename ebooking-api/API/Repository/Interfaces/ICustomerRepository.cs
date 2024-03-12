using Models.Domain;

namespace Repository.Interfaces;

public interface ICustomerRepository
{
    public Task<bool> AddCustomer(User user, Customer customer);
    public Task<Customer> GetCustomerDetails(int id, string JWT);
    public Task<IEnumerable<Customer>> GetAllCustomers();
    public Task<bool> UpdateCustomer(Customer customer);
    public Task<Customer> GetCustomerById(int id);
    public Task<Customer> GetCustomerByEmail(string email);
    public Task<bool> Delete(int id, string Authorization);
}
