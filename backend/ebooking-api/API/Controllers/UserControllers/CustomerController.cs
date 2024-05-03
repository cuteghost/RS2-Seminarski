using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Models.Domain;
using Models.DTO.UserDTO;
using Models.DTO.UserDTO.Customer;
using Models.Models.DTO.UserDTO;
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
        try
        {
            var user = _mapper.Map<User>(customerDto);
            var customer = _mapper.Map<Customer>(customerDto);

            if (await _customerRepo.AddCustomer(user, customer))
                return Content("Ok");
            else
                return Content("Error");
        }
        catch (Exception e)
        {
            return Content("Error: " + e.Message);
        }
    }

    [Authorize]
    [HttpGet]
    [Route("Details")]
    public async Task<IActionResult> GetCustomerDetails([FromHeader] string Authorization)
    {
        try
        {
            var id = _tokenHandler.GetCustomerIdFromJWT(Authorization);
            var customer = await _customerRepo.GetCustomerDetails(id, Authorization);
            if(customer == null) return Unauthorized();
            var toReturn = _mapper.Map<CustomerGET>(customer); 
            return Json(toReturn);
        }
        catch (Exception e)
        {
            return Content("Error: " + e);
        }
    }   
    
    [Authorize]
    [HttpDelete]
    [Route("Delete")]
    public async Task<IActionResult> DeleteCustomer([FromHeader] string Authorization)
    {
        try
        {
            var id = _tokenHandler.GetCustomerIdFromJWT(Authorization);
            if (await _customerRepo.Delete(id, Authorization))
                return Content("OK");
            else
                return Content("Not Found");
        }
        catch (Exception e)
        {
            return Content("Error: " + e.Message);
        }
    }

    [Authorize]
    [HttpPatch]
    [Route("UpdateDetails")]
    public async Task<IActionResult> UpdateCustomer([FromBody] CustomerPATCH customerDto, [FromHeader]string Authorization)
    {
        try
        {
            var id = _tokenHandler.GetCustomerIdFromJWT(Authorization);
            var customer = await _customerRepo.GetCustomerById(id);
            
            
            var userDomain = _mapper.Map<User>(customerDto);
            userDomain.Id = customer.User.Id;
            userDomain.Password = customer.User.Password;
            userDomain.Email = customer.User.Email;
            customer.User = userDomain;
            if(await _customerRepo.UpdateCustomer(customer))
                return Content("OK");
            else
                return Content("Error");
        }
        catch (Exception e)
        {
            
            return Content("Error: " + e.Message);
        }

    }
}
