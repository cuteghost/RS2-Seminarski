using Authentication.Services.HashService;
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

    public AdministratorRepository(ApplicationDbContext dbContext,
                                   IGenericRepository<Administrator> adminRepository,
                                   IGenericRepository<User> userRepository,
                                   IHashService hasher)
    {
        _dbContext = dbContext;
        _adminRepository = adminRepository;
        _userRepository = userRepository;
        _hasher = hasher;
    }

    public Task<object?> GetAllPartners()
    {
        throw new NotImplementedException();
    }
    public async Task<Administrator> GetAdminDetails(Guid id, string JWT)
    {
        var admin = await _adminRepository.Get(c => c.Id == id, false, c => c.User);

        if (admin == null) return null;
        admin.User.Password = "";
        return admin;
    }
}
