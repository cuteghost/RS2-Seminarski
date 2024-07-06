using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.ReservationDTO;
using Repository.Interfaces;
using Services.LocationService;
using Authentication.Services.TokenHandlerService;
using System.Linq;
using Services.RabbitMQService;
using Services;

namespace Controllers;
[ApiController]
[Route("/api/[controller]")]

public class ReservationController : Controller
{
    private readonly IGenericRepository<Reservation> _reservationRepo;
    private readonly IGenericRepository<Customer> _customerRepo;
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IGenericRepository<Review> _reviewRepo;
    private readonly ITokenHandlerService _tokenHandlerService;
    private readonly IMapper _mapper;
    private readonly IMessageProducer _messageProducer;

    public ReservationController(IGenericRepository<Reservation> reservationRepo,
                                 ITokenHandlerService tokenHandlerService,
                                 IMapper mapper,
                                 IGenericRepository<Review> reviewRepo,
                                 IGenericRepository<Customer> customerRepo,
                                 IGenericRepository<Accommodation> accommodationRepo,
                                 IMessageProducer messageProducer)
    {
        _reservationRepo = reservationRepo;
        _tokenHandlerService = tokenHandlerService;
        _mapper = mapper;
        _reviewRepo = reviewRepo;
        _customerRepo = customerRepo;
        _accommodationRepo = accommodationRepo;
        _messageProducer = messageProducer;
    }

    [HttpPost]
    [Route("Create")]
    public async Task<IActionResult> Create([FromBody] ReservationPOST reservationDto, [FromHeader] string Authorization)
    {
        //Check if Accommodation exists
        //Check if Customer exists
        var customerId = _tokenHandlerService.GetCustomerIdFromJWT(Authorization);
        var userId = _tokenHandlerService.GetUserIdFromJWT(Authorization);
        var customer = await _customerRepo.Get(c => c.Id == customerId, false);
        if (customer == null)
            return BadRequest("Customer doesn't exist!");
        var accommodation = await _accommodationRepo.Get(c => c.Id == reservationDto.AccommodationId, false, c => c.Owner, c => c.Owner.User);
        if (accommodation == null)
            return BadRequest("Accommodation doesn't exist!");
        if (accommodation.Owner == null)
            return BadRequest("Accommodation doesn't have an owner!");
        var ownerId = accommodation.Owner.UserId;
        var reservations = await _reservationRepo.GetAll(c => (c.StartDate.Date >= reservationDto.StartDate.Date && c.EndDate.Date <= reservationDto.EndDate.Date && c.AccommodationId == reservationDto.AccommodationId), false);
        if (reservations.Any())
            return BadRequest("Accommodation is taken");
        var reservation = _mapper.Map<Reservation>(reservationDto);
        reservation.CustomerId = customerId;
        await _reservationRepo.Add(reservation);


        WelcomeMessage message = new WelcomeMessage
        {
            User1Id = ownerId ?? Guid.Empty,
            User2Id = userId,
            Message = $"Dear Guest," +
                      $"\r\n\r\n" +
                      $"We are delighted to welcome you to {accommodation.Name}! " +
                      $"Thank you for choosing to stay with us. Our team is committed to ensuring that your experience is both comfortable and memorable." +
                      $"\r\n\r\nDuring your stay, we invite you to take full advantage of our amenities. " +
                      $"If there is anything you need or if you have any special requests, please do not hesitate to reach out to our friendly staff, available 24/7 to assist you.\r\n\r\n" +
                      $"To help you make the most of your visit check out suggestions app is offering.\r\n\r\n" +
                      $"We hope you have a wonderful stay and enjoy everything our city has to offer." +
                      $"\r\n\r\nWarm regards,\r\n\r\n{accommodation.Owner.User.DisplayName}\r\n\r\nCheck-In Date{reservation.StartDate} <-> Check-out Date{reservation.EndDate.Date}"
        };
        //strip time from dates

        _messageProducer.SendMessage(message);
        return Content("Reservation Made");
    }

    [HttpGet]
    [Route("CheckAvailability")]
    public async Task<IActionResult> CheckAvailability([FromQuery] Guid accommodationId)
    {
        var reservations = await _reservationRepo.GetAll(c => (c.AccommodationId == accommodationId), false);
        List<ReservedDatesDTO> reservedDates = new List<ReservedDatesDTO>();
        foreach (var reservation in reservations)
        {
            reservedDates.Add(new ReservedDatesDTO { StartDate = reservation.StartDate, EndDate = reservation.EndDate });
        }
        return Json(reservedDates);
    }
    [HttpGet]
    [Route("Customer/GetReservations")]
    public async Task<IActionResult> GetReservations([FromHeader] string Authorization)
    {
        var customerId = _tokenHandlerService.GetCustomerIdFromJWT(Authorization);
        var reservations = await _reservationRepo.GetAll(c => c.CustomerId == customerId, false, c => c.accommodation, c => c.accommodation.AccommodationDetails, c => c.accommodation.Location, c=> c.accommodation.AccommodationImages);
        var reviews = await _reviewRepo.GetAll(c => c.CustomerId == customerId, false);
        var toReturn = _mapper.Map<List<ReservationGET>>(reservations);
        foreach(var r in toReturn)
        {
            foreach(var review in reviews)
            {
                if (r.AccommodationId == review.AccommodationId)
                { 
                    r.IsRated = true;
                }
            }
            r.Thumbnail = r.accommodation.AccommodationImages.Image1;
            r.accommodation.AccommodationImages = null;
        }
        return Json(toReturn);
    }
}
