using Database;
using eBooking.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Repository.Interfaces;
using Services.HashService;
using Services.TokenHandlerService;

namespace Repository.Classes;

public class CustomerRepository : ICustomerRepository
{
    private readonly ApplicationDbContext _dbContext;
    private readonly IGenericRepository<Customer> _customerRepository;
    private readonly IGenericRepository<User> _userRepository;
    private readonly IHashService _hasher;
    private readonly ITokenHandlerService _tokenHandler;
    
    public CustomerRepository(IHashService hasher, IGenericRepository<Customer> customerRepository, IGenericRepository<User> userRepository, ApplicationDbContext applicationDbContext, ITokenHandlerService tokenHandler)
    {
        _customerRepository = customerRepository;
        _userRepository = userRepository;
        _hasher = hasher;
        _dbContext = applicationDbContext;
        _tokenHandler = tokenHandler;
    }
    
    public async Task<bool> AddCustomer(User user, Customer customer)
    {
        try
        {
            user.Password = _hasher.Hash(user.Password);
            await _userRepository.Add(user);

            customer.User = user;

            await _customerRepository.Add(customer);

            return true;
        }
        catch (Exception)
        {

            throw;
        }
    }

    public async Task<IEnumerable<Customer>> GetAllCustomers()
    {
        try
        {
            
            return await _customerRepository.GetAll(false, c => c.User);
        }
        catch (Exception)
        {

            throw;
        }
    }

    public async Task<Customer> GetCustomerDetails(Guid id, string JWT)
    {
        try
        {
            ;
            var customer = await _customerRepository.GetById(c => c.Id == id, false, c => c.User);
            
            if (customer == null) return null;
            if (_tokenHandler.GetEmailFromJWT(JWT) != customer.User.Email) return null;
            customer.User.Password = "";
            return customer;
        }
        catch (Exception)
        {

            throw;
        }
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
        return await _customerRepository.GetById(c => c.Id == id, false, c => c.User);
    }

    public async Task<Customer> GetCustomerByEmail(string email)
    {
        return await _dbContext.Customers.Include(c => c.User).Where(u => u.User.Email == email).AsNoTracking().FirstOrDefaultAsync();
    }

    public async Task<bool> Delete(Guid id, string JWT)
    {
        var customer = await GetCustomerById(id);
        if (customer == null) return false;
        if (customer.User.Email != _tokenHandler.GetEmailFromJWT(JWT)) return false;
        if (await _customerRepository.Delete(c => c.Id == id))
            if (await _userRepository.Delete(c => c.Id == customer.User.Id))
                return true;

        return false;
    }
}
