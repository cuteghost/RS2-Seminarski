using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Models.Domain;
using Models.DTO.UserDTO.Administrator;
using Repository.Interfaces;
using Authentication.Services.TokenHandlerService;
using Models.DTO.UserDTO.Customer;
using EasyNetQ;
using Models.DTO.AccommodationDTO;
using Models.DTO.UserDTO;
using Models.DTO.ReservationDTO;

namespace Controllers.UserControllers;

[ApiController]
[Route("/api/[controller]")]
public class AdministratorController : Controller
{
    private readonly IGenericRepository<User> _userRepo;
    private readonly IGenericRepository<Customer> _customerRepo;
    private readonly IGenericRepository<Partner> _partnerRepo;
    private readonly IAdministratorRepository _adminRepo;
    private readonly IGenericRepository<Reservation> _reservationRepo;
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IMapper _mapper;
    private readonly ITokenHandlerService _tokenHandler;
    public AdministratorController(IGenericRepository<User> userRepo, 
                                   IMapper mapper, 
                                   ITokenHandlerService tokenHandlerService, 
                                   IAdministratorRepository adminRepo, 
                                   IGenericRepository<Reservation> reservationRepo, 
                                   IGenericRepository<Accommodation> accommodationRepo,
                                   IGenericRepository<Customer> customerRepo,
                                   IGenericRepository<Partner> partnerRepo)
    {
        _userRepo = userRepo;
        _mapper = mapper;
        _tokenHandler = tokenHandlerService;
        _adminRepo = adminRepo;
        _reservationRepo = reservationRepo;
        _accommodationRepo = accommodationRepo;
        _customerRepo = customerRepo;
        _partnerRepo = partnerRepo;
    }

    [Authorize]
    [HttpGet]
    [Route("Customers")]
    public async Task<IActionResult> GetCustomers([FromHeader] string Authorization)
    {
        if (_tokenHandler.GetAdministratorIdFromJWT(Authorization) == Guid.Empty) return Unauthorized();
        var customers = await _customerRepo.GetAll(false, u => u.User);
        var toReturn = _mapper.Map<List<CustomerGET>>(customers);
        return Json(toReturn);
    }

    [Authorize]
    [HttpGet]
    [Route("GetPartners")]
    public async Task<IActionResult> GetPartners([FromHeader] string Authorization)
    {
        if (_tokenHandler.GetAdministratorIdFromJWT(Authorization) == null) return Unauthorized();
        return Json(await _adminRepo.GetAllPartners());
    }


    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> RegisterAdministrator([FromBody] AdministratorPOST userDto)
    {
        var user = _mapper.Map<User>(userDto);
        await _userRepo.Add(user);

        return Content("Ok");
    }

    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> DeleteUser([FromRoute] Guid id)
    {
        if (await _userRepo.Delete(u => u.Id == id))
            return Content("OK");
        else
            return Content("Not Found");
    }

    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> UpdateUser([FromBody] AdministratorPATCH userDto)
    {

        var user = _mapper.Map<User>(userDto);
        if (await _userRepo.Update(c => c.Id == user.Id, user))
            return Content("OK");
        else
            return Content("Not Found");
    }

    [Authorize]
    [HttpGet]
    [Route("Details")]
    public async Task<IActionResult> GetCustomerDetails([FromHeader] string Authorization)
    {
        try
        {
            var id = _tokenHandler.GetAdministratorIdFromJWT(Authorization);
            var admin = await _adminRepo.GetAdminDetails(id, Authorization);
            if (admin == null) return Unauthorized();
            var toReturn = _mapper.Map<AdministratorGET>(admin);
            return Json(toReturn);
        }
        catch (Exception e)
        {
            return Content("Error: " + e);
        }
    }

    [Authorize]
    [HttpGet]
    [Route("Reservations")]
    public async Task<IActionResult> GetRents([FromHeader] string Authorization, [FromQuery] DateTime start, [FromQuery] DateTime end)
    {
        if (_tokenHandler.GetAdministratorIdFromJWT(Authorization) == Guid.Empty) return Unauthorized();
        var reservations = await _reservationRepo.GetAll(r => r.StartDate >= start && r.EndDate <= end, false, r => r.accommodation, r => r.accommodation.AccommodationDetails, r => r.accommodation.Location, r => r.accommodation.AccommodationImages);
        var toReturn = _mapper.Map<List<ReservationGET>>(reservations);
        foreach (var r in toReturn)
        { 
            r.Thumbnail = r.accommodation.AccommodationImages.Image1;
            r.accommodation.AccommodationImages = null;
        }
        return Json(toReturn);
    }

    [Authorize(Roles="Administrator")]
    [HttpGet]
    [Route("Accommodations")]
    public async Task<IActionResult> GetAccommodations([FromHeader] string Authorization)
    {
        if (_tokenHandler.GetAdministratorIdFromJWT(Authorization) == Guid.Empty) return Unauthorized();
        var rawAccommodations = await _accommodationRepo.GetAll(includeDeleted: false, a => a.Location, a => a.Owner, a => a.AccommodationImages, a => a.AccommodationDetails);
        var toReturn = _mapper.Map<List<AccommodationGET>>(rawAccommodations);
        return Json(toReturn);
    }

    [Authorize]
    [HttpDelete]
    [Route("DeleteUser")]
    public async Task<IActionResult> DeleteUser([FromHeader] string Authorization, [FromQuery] Guid userId)
    {
        if (_tokenHandler.GetAdministratorIdFromJWT(Authorization) == Guid.Empty) return Unauthorized();
        await _userRepo.Delete(u => u.Id == userId);
        return Ok();
    }
}
