using Database;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Repository.Interfaces;
using Authentication.Services.HashService;

namespace Repository.Classes;

public class CustomerRepository : ICustomerRepository
{
    private readonly ApplicationDbContext _dbContext;
    private readonly IGenericRepository<Customer> _customerRepository;
    private readonly IGenericRepository<User> _userRepository;
    private readonly IHashService _hasher;

    public CustomerRepository(IHashService hasher, IGenericRepository<Customer> customerRepository, IGenericRepository<User> userRepository, ApplicationDbContext applicationDbContext)
    {
        _customerRepository = customerRepository;
        _userRepository = userRepository;
        _hasher = hasher;
        _dbContext = applicationDbContext;
    }

    public async Task<bool> AddCustomer(User user, Customer customer)
    {
        if (await _userRepository.Get(u => u.Email == user.Email) != null) return false;
        user.Password = _hasher.Hash(user.Password);
        await _userRepository.Add(user);

        customer.User = user;

        await _customerRepository.Add(customer);

        return true;
    }

    public async Task<Customer> GetCustomerDetails(Guid id, string JWT)
    {
        var customer = await _customerRepository.Get(c => c.Id == id, false, c => c.User);

        if (customer == null) return null;
        customer.User.Password = "";
        return customer;
    }

    public async Task<bool> UpdateCustomer(Customer customer)
    {
        if (await _customerRepository.Update(c => c.Id == customer.Id, customer))
            if (await _userRepository.Update(c => c.Id == customer.User.Id, customer.User))
                return true;
        return false;
    }
    public async Task<Customer> GetCustomerById(Guid id)
    {
        return await _customerRepository.Get(c => c.Id == id, false, c => c.User);
    }

    public async Task<Customer> GetCustomerByEmail(string email)
    {
        return await _dbContext.Customers.Include(c => c.User).Where(u => u.User.Email == email).AsNoTracking().FirstOrDefaultAsync();
    }

    public async Task<bool> Delete(Guid id, string JWT)
    {
        var customer = await GetCustomerById(id);
        if (customer == null) return false;
        if (await _customerRepository.Delete(c => c.Id == id))
            if (await _userRepository.Delete(c => c.Id == customer.User.Id))
                return true;

        return false;
    }
}
