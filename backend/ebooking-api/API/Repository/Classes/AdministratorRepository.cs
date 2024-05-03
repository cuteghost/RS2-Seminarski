using Models.Domain;
using Repository.Interfaces;

namespace Repository.Classes
{
    public class AdministratorRepository : IAdministratorRepository
    {
        public Task<IEnumerable<Customer>> GetAllCustomers()
        {
            throw new NotImplementedException();
        }

        public Task<object?> GetAllPartners()
        {
            throw new NotImplementedException();
        }
    }
}
