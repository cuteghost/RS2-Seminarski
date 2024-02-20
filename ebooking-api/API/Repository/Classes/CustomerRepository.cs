using eBooking.Services.Interfaces;
using Microsoft.AspNetCore.Identity;
using Models.Domain;
using Repository.Interfaces;
using Services.HashService;

namespace Repository.Classes;

public class CustomerRepository : ICustomerRepository
{
    private readonly IGenericRepository<Customer> _customerRepository;
    private readonly IGenericRepository<User> _userRepository;
    private readonly IHashService _hasher;
    
    public CustomerRepository(IHashService hasher, IGenericRepository<Customer> customerRepository, IGenericRepository<User> userRepository)
    {
        _customerRepository = customerRepository;
        _userRepository = userRepository;
        _hasher = hasher;
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
}
