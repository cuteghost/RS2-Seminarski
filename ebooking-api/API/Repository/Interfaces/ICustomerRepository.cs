using eBooking.Services.Interfaces;
using Microsoft.EntityFrameworkCore.Query.Internal;
using Models.Domain;

namespace Repository.Interfaces;

public interface ICustomerRepository
{
    public Task<bool> AddCustomer(User user, Customer customer);
}
