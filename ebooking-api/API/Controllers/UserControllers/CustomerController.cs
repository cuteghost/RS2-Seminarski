using AutoMapper;
using eBooking.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.UserDTO.Customer;
using Repository.Interfaces;

namespace API.Controllers.UserControllers;

[ApiController]
[Route("/api/[controller]")]
public class CustomerController : Controller
{
    private readonly ICustomerRepository _customerRepo;
    private readonly IMapper _mapper;
    public CustomerController(ICustomerRepository customerRepo, IMapper mapper)
    {
        _customerRepo = customerRepo;
        _mapper = mapper;
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
    //[HttpGet]
    //[Route("GetUsers")]
    //public async Task<IActionResult> GetUsers()
    //{
    //    return Json(await _customerRepo.GetAll());
    //}
    //[HttpDelete]
    //[Route("Delete/{id}")]
    //public async Task<IActionResult> DeleteUser([FromRoute] int id)
    //{
    //    if (await _customerRepo.Delete(u => u.Id == id))
    //        return Content("OK");
    //    else
    //        return Content("Not Found");
    //}
    //[HttpPatch]
    //[Route("Update")]
    //public async Task<IActionResult> UpdateUser([FromBody] CustomerPATCH userDto)
    //{

    //    var user = _mapper.Map<Customer>(userDto);
    //    if (await _customerRepo.Update(c => c.Id == user.Id, user))
    //        return Content("OK");
    //    else
    //        return Content("Not Found");
    //}
}
