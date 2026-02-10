using API.Exceptions;
using API.Extensions;
using AutoMapper;
using Database.Services.AccommodationCatalogService;
using Database.Services.AccommodationImageService;
using Database.Services.AccountService;
using Database.Services.PaymentService;
using Database.Services.ProfileService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.Domain;
using Models.DTO.AccommodationDTO;
using Models.DTO.ReservationDTO;
using Models.DTO.UserDTO;
using Models.DTO.UserDTO.Administrator;
using Models.DTO.UserDTO.Customer;
using Models.DTO.UserDTO.Partner;
using Repository.Interfaces;
using Services.CurrentUserService;
using System.Linq.Expressions;

namespace Controllers.UserControllers;

[ApiController]
[Authorize(Roles = Roles.Administrator)]
[Route("/api/[controller]")]
public class AdministratorController : Controller
{
    private readonly IUserRepository _userRepo;
    private readonly IGenericRepository<User> _userGenericRepo;
    private readonly IAccountService _accountService;
    private readonly IProfileService _profileService;
    private readonly IGenericRepository<Customer> _customerRepo;
    private readonly IGenericRepository<Partner> _partnerRepo;
    private readonly IAdministratorRepository _adminRepo;
    private readonly IGenericRepository<Reservation> _reservationRepo;
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IMapper _mapper;
    private readonly ICurrentUserService _currentUser;
    private readonly IPaymentService _paymentService;
    private readonly IAccommodationImageService _imageService;
    private readonly IAccommodationCatalogService _catalog;

    public AdministratorController(IUserRepository userRepo,
                                   IGenericRepository<User> userGenericRepo,
                                   IAccountService accountService,
                                   IProfileService profileService,
                                   IMapper mapper,
                                   ICurrentUserService currentUser,
                                   IAdministratorRepository adminRepo,
                                   IGenericRepository<Reservation> reservationRepo,
                                   IGenericRepository<Accommodation> accommodationRepo,
                                   IGenericRepository<Customer> customerRepo,
                                   IGenericRepository<Partner> partnerRepo,
                                   IPaymentService paymentService,
                                   IAccommodationImageService imageService,
                                   IAccommodationCatalogService catalog)
    {
        _userRepo = userRepo;
        _userGenericRepo = userGenericRepo;
        _accountService = accountService;
        _profileService = profileService;
        _mapper = mapper;
        _currentUser = currentUser;
        _adminRepo = adminRepo;
        _reservationRepo = reservationRepo;
        _accommodationRepo = accommodationRepo;
        _customerRepo = customerRepo;
        _partnerRepo = partnerRepo;
        _paymentService = paymentService;
        _imageService = imageService;
        _catalog = catalog;
    }

    [HttpGet]
    [Route("Customers")]
    public async Task<IActionResult> GetCustomers([FromQuery] int page = 1, [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var (items, totalCount) = await _customerRepo.GetPaged(page, pageSize, false, u => u.User);
        var customers = _mapper.Map<List<CustomerGET>>(items);

        return Ok(new PagedResponse<CustomerGET>("Customers retrieved successfully.", customers, page, pageSize, totalCount));
    }

    [HttpGet]
    [Route("GetPartners")]
    public async Task<IActionResult> GetPartners([FromQuery] int page = 1, [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var (items, totalCount) = await _partnerRepo.GetPaged(page, pageSize, false, p => p.User);
        var partners = _mapper.Map<List<PartnerGET>>(items);

        return Ok(new PagedResponse<PartnerGET>("Partners retrieved successfully.", partners, page, pageSize, totalCount));
    }

    [HttpGet]
    [Route("Users")]
    public async Task<IActionResult> GetUsers([FromQuery] string? search = null,
                                               [FromQuery] Models.DTO.UserDTO.Role? role = null,
                                               [FromQuery] bool? isActive = null,
                                               [FromQuery] int page = 1,
                                               [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var predicate = MatchesUserFilters(search, role, isActive);

        var (items, totalCount) = await _userGenericRepo.GetPaged(predicate, page, pageSize);
        var mapped = _mapper.Map<List<UserListItemGET>>(items);

        return Ok(new PagedResponse<UserListItemGET>("Users retrieved successfully.", mapped, page, pageSize, totalCount));
    }

    private static Expression<Func<User, bool>> MatchesUserFilters(
        string? search, Models.DTO.UserDTO.Role? role, bool? isActive)
    {
        var term = string.IsNullOrWhiteSpace(search) ? null : search.Trim();
        var domainRole = role.HasValue ? ToDomainRole(role.Value) : (Models.Domain.Role?)null;

        return user =>
            (term == null ||
             user.DisplayName.Contains(term) ||
             user.FirstName.Contains(term) ||
             user.LastName.Contains(term) ||
             user.Email.Contains(term)) &&
            (!domainRole.HasValue || user.Role == domainRole.Value) &&
            (!isActive.HasValue || user.IsActive == isActive.Value);
    }

    private static Models.Domain.Role ToDomainRole(Models.DTO.UserDTO.Role role) => role switch
    {
        Models.DTO.UserDTO.Role.Administrator => Models.Domain.Role.AdministratorRole,
        Models.DTO.UserDTO.Role.Partner => Models.Domain.Role.PartnerRole,
        _ => Models.Domain.Role.CustomerRole,
    };

    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> RegisterAdministrator([FromBody] AdministratorPOST userDto)
    {
        if (string.IsNullOrWhiteSpace(userDto.Email))
            throw new BusinessException("Email address is required.");

        if (string.IsNullOrWhiteSpace(userDto.Password))
            throw new BusinessException("Password is required.");

        var user = _mapper.Map<User>(userDto);
        var creatorId = await _currentUser.GetAdministratorIdAsync();

        var administrator = await _adminRepo.AddAdministrator(user, creatorId);

        return Ok(new BaseResponse<AdministratorGET>("Administrator created successfully.", _mapper.Map<AdministratorGET>(administrator)));
    }

    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> UpdateUser([FromBody] AdministratorPATCH userDto)
    {
        var administratorId = await _currentUser.GetAdministratorIdAsync();

        var changes = _mapper.Map<User>(userDto);
        var updated = await _adminRepo.UpdateAdministrator(administratorId, changes);
        if (updated == null)
            throw new NotFoundException("The logged-in account is not registered as an administrator.");

        return Ok(new BaseResponse<AdministratorGET>("Administrator data updated successfully.", _mapper.Map<AdministratorGET>(updated)));
    }

    [HttpPatch]
    [Route("UpdateUser/{userId}")]
    public async Task<IActionResult> UpdateManagedUser([FromRoute] Guid userId, [FromBody] ManagedUserPATCH changes)
    {
        var updated = await _profileService.UpdateUserByAdministrator(_currentUser.UserId, userId, changes);

        return Ok(new BaseResponse<UserGET>("User data updated successfully.", _mapper.Map<UserGET>(updated)));
    }

    [HttpPatch]
    [Route("ResetPassword/{userId}")]
    public async Task<IActionResult> ResetUserPassword([FromRoute] Guid userId, [FromBody] ManagedUserPasswordPATCH newCredentials)
    {
        await _userRepo.SetPasswordAsAdministrator(_currentUser.UserId, userId, newCredentials.NewPassword);

        return Ok(new BaseResponse<object>("User password set successfully. The user must log in again.", null));
    }

    [HttpGet]
    [Route("Details")]
    public async Task<IActionResult> GetCustomerDetails()
    {
        var id = await _currentUser.GetAdministratorIdAsync();
        var admin = await _adminRepo.GetAdminDetails(id);
        if (admin == null)
            throw new NotFoundException("The logged-in account is not registered as an administrator.");

        return Ok(new BaseResponse<AdministratorGET>("Administrator data retrieved successfully.", _mapper.Map<AdministratorGET>(admin)));
    }

    [HttpGet]
    [Route("Reservations")]
    public async Task<IActionResult> GetRents([FromQuery] DateTime start,
                                              [FromQuery] DateTime end,
                                              [FromQuery] string? search = null,
                                              [FromQuery] ReservationStatus? status = null,
                                              [FromQuery] int page = 1,
                                              [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        if (end.Date < start.Date)
            throw new BusinessException("The end of the period must not be before the start of the period.");

        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var predicate = MatchesReservationFilters(start, end, search, status);

        var (items, totalCount) = await _reservationRepo.GetPaged(
            predicate, page, pageSize, false,
            r => r.accommodation, r => r.accommodation.AccommodationType, r => r.accommodation.AccommodationDetails, r => r.accommodation.Location, r => r.accommodation.Location.City, r => r.accommodation.Location.City.Country);

        var toReturn = _mapper.Map<List<ReservationGET>>(items);
        var paidReservationIds = await _paymentService.GetPaidReservationIds(toReturn.Select(r => r.Id).ToList());
        await _imageService.AttachThumbnails(toReturn);
        foreach (var reservation in toReturn)
        {
            reservation.IsPaid = paidReservationIds.Contains(reservation.Id);
        }

        return Ok(new PagedResponse<ReservationGET>("Reservations retrieved successfully.", toReturn, page, pageSize, totalCount));
    }

    private static Expression<Func<Reservation, bool>> MatchesReservationFilters(
        DateTime start, DateTime end, string? search, ReservationStatus? status)
    {
        var term = string.IsNullOrWhiteSpace(search) ? null : search.Trim();

        return reservation =>
            reservation.StartDate >= start && reservation.EndDate <= end &&
            (term == null ||
             (reservation.accommodation != null && reservation.accommodation.Name.Contains(term))) &&
            (!status.HasValue || reservation.Status == status.Value);
    }

    [HttpGet]
    [Route("Accommodations")]
    public async Task<IActionResult> GetAccommodations([FromQuery] string? search = null,
                                                        [FromQuery] Guid? cityId = null,
                                                        [FromQuery] Guid? accommodationTypeId = null,
                                                        [FromQuery] bool? status = null,
                                                        [FromQuery] int page = 1,
                                                        [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var predicate = MatchesAccommodationFilters(search, cityId, accommodationTypeId, status);

        var (items, totalCount) = await _accommodationRepo.GetPaged(predicate, page, pageSize, false,
            a => a.Location, a => a.Location.City, a => a.Location.City.Country, a => a.Owner, a => a.AccommodationDetails, a => a.AccommodationType);
        var accommodations = _mapper.Map<List<AccommodationGET>>(items);
        await _imageService.Attach(accommodations);
        await _catalog.AttachAmenities(accommodations);

        return Ok(new PagedResponse<AccommodationGET>("Accommodations retrieved successfully.", accommodations, page, pageSize, totalCount));
    }

    private static Expression<Func<Accommodation, bool>> MatchesAccommodationFilters(
        string? search, Guid? cityId, Guid? accommodationTypeId, bool? status)
    {
        var term = string.IsNullOrWhiteSpace(search) ? null : search.Trim();

        return accommodation =>
            (term == null ||
             accommodation.Name.Contains(term) ||
             (accommodation.Location != null && accommodation.Location.Address.Contains(term)) ||
             (accommodation.Location != null && accommodation.Location.City != null &&
              accommodation.Location.City.Name.Contains(term))) &&
            (!cityId.HasValue ||
             (accommodation.Location != null && accommodation.Location.CityId == cityId.Value)) &&
            (!accommodationTypeId.HasValue || accommodation.AccommodationTypeId == accommodationTypeId.Value) &&
            (!status.HasValue || accommodation.Status == status.Value);
    }

    [HttpDelete]
    [Route("DeleteUser")]
    public async Task<IActionResult> DeleteUser([FromQuery] Guid userId)
    {
        await _accountService.DeleteUserByAdministrator(_currentUser.UserId, userId);

        return Ok(new BaseResponse<object>("User deleted successfully.", null));
    }
}
