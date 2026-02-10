using API.Exceptions;
using AutoMapper;
using Database.Services.AccountService;
using Database.Services.ProfileService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.UserDTO.Customer;
using Repository.Interfaces;
using Services.CurrentUserService;
using System.Text.RegularExpressions;

namespace API.Controllers.UserControllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class CustomerController : Controller
{
    private static readonly TimeSpan ValidationTimeout = TimeSpan.FromMilliseconds(200);

    private static readonly Regex EmailFormat = new(
        @"^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$",
        RegexOptions.Compiled,
        ValidationTimeout);

    private static readonly Regex LettersOnly = new(
        @"^\p{L}+$",
        RegexOptions.Compiled,
        ValidationTimeout);

    private readonly ICustomerRepository _customerRepo;
    private readonly IMapper _mapper;
    private readonly ICurrentUserService _currentUser;
    private readonly IAccountService _accountService;
    private readonly IProfileService _profileService;

    public CustomerController(ICustomerRepository customerRepo, IMapper mapper, ICurrentUserService currentUser,
                              IAccountService accountService, IProfileService profileService)
    {
        _customerRepo = customerRepo;
        _mapper = mapper;
        _currentUser = currentUser;
        _accountService = accountService;
        _profileService = profileService;
    }

    [AllowAnonymous]
    [HttpPost]
    [Route("Register")]
    public async Task<IActionResult> Register([FromBody] CustomerPOST customerDto)
    {
        customerDto.Email = (customerDto.Email ?? string.Empty).Trim();
        customerDto.FirstName = (customerDto.FirstName ?? string.Empty).Trim();
        customerDto.LastName = (customerDto.LastName ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(customerDto.Email))
            throw new BusinessException("Email address is required.");

        if (!EmailFormat.IsMatch(customerDto.Email))
            throw new BusinessException("Email address is not in a valid format. Expected form is name@domain.ba, without spaces or special characters.");

        if (string.IsNullOrWhiteSpace(customerDto.Password))
            throw new BusinessException("Password is required.");

        if (!LettersOnly.IsMatch(customerDto.FirstName))
            throw new BusinessException("First name is required and may contain only letters, without digits, spaces or special characters.");

        if (!LettersOnly.IsMatch(customerDto.LastName))
            throw new BusinessException("Last name is required and may contain only letters, without digits, spaces or special characters.");

        var user = _mapper.Map<User>(customerDto);
        var customer = _mapper.Map<Customer>(customerDto);

        // Ranije se svaki izuzetak vracao klijentu kao "Error: " + e.Message, cime je poruka
        // iz baze zavrsavala na ekranu korisnika. Sada neocekivane greske hvata
        // GlobalExceptionHandler, a ocekivane se javljaju kao BusinessException.
        if (!await _customerRepo.AddCustomer(user, customer))
            throw new BusinessException("An account with that email address already exists.");

        return Ok(new BaseResponse<CustomerGET>("Registration successful.", _mapper.Map<CustomerGET>(customer)));
    }

    [HttpGet]
    [Route("Details")]
    public async Task<IActionResult> GetCustomerDetails()
    {
        var id = await _currentUser.GetCustomerIdAsync();
        var customer = await _customerRepo.GetCustomerDetails(id);
        if (customer == null)
            throw new NotFoundException("The logged-in account is not registered as a customer.");

        return Ok(new BaseResponse<CustomerGET>("Customer data retrieved successfully.", _mapper.Map<CustomerGET>(customer)));
    }

    [HttpDelete]
    [Route("Delete")]
    public async Task<IActionResult> DeleteCustomer()
    {
        await _accountService.DeleteOwnAccount(_currentUser.UserId);

        return Ok(new BaseResponse<object>("Account deleted successfully.", null));
    }

    [HttpPatch]
    [Route("UpdateDetails")]
    public async Task<IActionResult> UpdateCustomer([FromBody] CustomerPATCH customerDto)
    {
        var id = await _currentUser.GetCustomerIdAsync();
        if (id == Guid.Empty)
            throw new NotFoundException("The logged-in account is not registered as a customer.");

        await _profileService.UpdateUserProfile(_currentUser.UserId, customerDto);

        var updated = await _customerRepo.GetCustomerDetails(id);

        return Ok(new BaseResponse<CustomerGET>("Customer data updated successfully.", _mapper.Map<CustomerGET>(updated)));
    }
}
