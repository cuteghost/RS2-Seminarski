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
        if (await _dbContext.Users.AnyAsync(u => u.Email == user.Email)) return false;
        user.Password = _hasher.Hash(user.Password);
        await _userRepository.Add(user);

        customer.User = user;

        await _customerRepository.Add(customer);

        return true;
    }

    public async Task<Customer> GetCustomerDetails(Guid id)
    {
        var customer = await _customerRepository.Get(c => c.Id == id, false, c => c.User);

        if (customer == null) return null;
        customer.User.Password = "";
        return customer;
    }

    public async Task<Customer> GetCustomerByEmail(string email)
    {
        return await _dbContext.Customers.Include(c => c.User).Where(u => u.User.Email == email).AsNoTracking().FirstOrDefaultAsync();
    }
}
