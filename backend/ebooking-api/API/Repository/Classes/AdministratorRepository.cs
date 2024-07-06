using Authentication.Services.HashService;
using Authentication.Services.TokenHandlerService;
using Database;
using Models.Domain;
using Repository.Interfaces;

namespace Repository.Classes;

public class AdministratorRepository : IAdministratorRepository
{
    private readonly ApplicationDbContext _dbContext;
    private readonly IGenericRepository<Administrator> _adminRepository;
    private readonly IGenericRepository<User> _userRepository;
    private readonly IHashService _hasher;
    private readonly ITokenHandlerService _tokenHandler;

    public AdministratorRepository(ApplicationDbContext dbContext,
                                   IGenericRepository<Administrator> adminRepository,
                                   IGenericRepository<User> userRepository,
                                   IHashService hasher,
                                   ITokenHandlerService tokenHandlerService)
    {
        _dbContext = dbContext;
        _adminRepository = adminRepository;
        _userRepository = userRepository;
        _hasher = hasher;
        _tokenHandler = tokenHandlerService;
    }

    public Task<IEnumerable<Customer>> GetAllCustomers()
    {
        throw new NotImplementedException();
    }

    public Task<object?> GetAllPartners()
    {
        throw new NotImplementedException();
    }
    public async Task<Administrator> GetAdminDetails(Guid id, string JWT)
    {
        try
        {
            var admin = await _adminRepository.Get(c => c.Id == id, false, c => c.User);

            if (admin == null) return null;
            if (_tokenHandler.GetEmailFromJWT(JWT) != admin.User.Email) return null;
            admin.User.Password = "";
            return admin;
        }
        catch (Exception)
        {

            throw;
        }
    }
}
