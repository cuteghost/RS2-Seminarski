using API.Exceptions;
using Authentication.Services.HashService;
using Database;
using Microsoft.EntityFrameworkCore;
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

    public async Task<Administrator> GetAdminDetails(Guid id)
    {
        var admin = await _adminRepository.Get(c => c.Id == id, false, c => c.User);

        if (admin == null) return null;
        admin.User.Password = "";
        return admin;
    }

    /// <summary>
    /// Ranije se upisivao samo red u <c>Users</c>, bez reda u <c>Administrators</c>, pa nalog nije
    /// dobijao nijednu ulogu i nije se mogao prijaviti. Oba reda sada nastaju zajedno: EF ih upisuje
    /// kroz jedan <c>SaveChangesAsync</c>, pa nije potrebna eksplicitna transakcija.
    /// </summary>
    public async Task<Administrator> AddAdministrator(User user, Guid creatorId)
    {
        if (await _dbContext.Users.AnyAsync(u => u.Email == user.Email))
            throw new BusinessException("An account with that email address already exists.");

        user.Id = Guid.NewGuid();
        user.Password = _hasher.Hash(user.Password);
        user.Role = Role.AdministratorRole;
        user.Joined = DateTime.UtcNow;
        user.IsActive = true;

        var administrator = new Administrator
        {
            Id = Guid.NewGuid(),
            User = user,
            CreatorId = creatorId == Guid.Empty ? null : creatorId,
            Joined = DateTime.UtcNow,
            IsDeleted = false,
        };

        await _dbContext.Administrators.AddAsync(administrator);
        await _dbContext.SaveChangesAsync();

        administrator.User.Password = "";
        return administrator;
    }

    public async Task<Administrator> UpdateAdministrator(Guid administratorId, User changes)
    {
        var administrator = await _dbContext.Administrators
            .Include(a => a.User)
            .FirstOrDefaultAsync(a => a.Id == administratorId && !a.IsDeleted);

        if (administrator == null) return null;

        administrator.User.DisplayName = changes.DisplayName;
        administrator.User.FirstName = changes.FirstName;
        administrator.User.LastName = changes.LastName;
        administrator.User.BirthDate = changes.BirthDate;
        administrator.User.Gender = changes.Gender;

        if (changes.Image != null)
            administrator.User.Image = changes.Image;

        await _dbContext.SaveChangesAsync();

        administrator.User.Password = "";
        return administrator;
    }
}
