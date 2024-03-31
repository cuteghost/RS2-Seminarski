using AutoMapper;
using eBooking.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Models.Domain;
using Models.DTO.UserDTO;
using Models.DTO.UserDTO.Customer;
using Repository.Interfaces;
using Services.TokenHandlerService;

namespace API.Controllers.UserControllers;

[ApiController]
[Route("/api/[controller]")]
public class CustomerController : Controller
{
    private readonly ICustomerRepository _customerRepo;
    private readonly IMapper _mapper;
    private readonly ITokenHandlerService _tokenHandler;
    public CustomerController(ICustomerRepository customerRepo, IMapper mapper, ITokenHandlerService tokenHandler)
    {
        _customerRepo = customerRepo;
        _mapper = mapper;
        _tokenHandler = tokenHandler;
    }

    [HttpPost]
    [Route("Register")]
    public async Task<IActionResult> Register([FromBody] CustomerPOST customerDto)
    {
        var user = _mapper.Map<User>(customerDto);
        var customer = _mapper.Map<Customer>(customerDto);
        await _customerRepo.AddCustomer(user, customer);

        return Content("Ok");
    }
    
    [HttpGet]
    [Route("GetUsers")]
    public async Task<IActionResult> GetUsers()
    {
        return Json(await _customerRepo.GetAllCustomers());
    }
    
    [Authorize]
    [HttpGet]
    [Route("details/{id}")]
    public async Task<IActionResult> GetCustomerDetails([FromRoute] Guid id, [FromHeader] string Authorization)
    {
        try
        {
            var customer = await _customerRepo.GetCustomerDetails(id, Authorization);
            if(customer == null) return Unauthorized();
            var toReturn = _mapper.Map<CustomerGET>(customer); 
            return Json(toReturn);
        }
        catch (Exception)
        {
            return Unauthorized();
            throw;
        }
    }
    [Authorize]
    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> DeleteUser([FromRoute] Guid id, [FromHeader] string Authorization)
    {
        if (await _customerRepo.Delete(id, Authorization))
            return Content("OK");
        else
            return Content("Not Found");
    }

    [Authorize]
    [HttpPatch]
    [Route("update/{id}")]
    public async Task<IActionResult> UpdateUser([FromBody] CustomerPATCH customerDto, [FromRoute] Guid id)
    {
        var customer = await _customerRepo.GetCustomerById(id);
         

        var userDomain = _mapper.Map<User>(customerDto);
        userDomain.Id = customer.User.Id;
        userDomain.Password = customer.User.Password;
        customer.User = userDomain;
        await _customerRepo.UpdateCustomer(customer);

        return Ok();
    }
}
