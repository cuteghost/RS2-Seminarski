using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;
using Models.DTO.AccommodationDTO;
using Repository.Interfaces;

namespace Controllers;

[ApiController]
[Route("/api/[controller]")]
public class SearchController : Controller
{
    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IGenericRepository<Reservation> _reservations;
    private readonly IMapper _mapper;

    public SearchController(IGenericRepository<Accommodation> accommodationRepo, IMapper mapper, IGenericRepository<Reservation> reservations)
    {
        _accommodationRepo = accommodationRepo;
        _mapper = mapper;
        _reservations = reservations;
    }

    [HttpGet]
    public async Task<IActionResult> Search([FromQuery] double priceFrom, 
                                [FromQuery] double priceTo, 
                                [FromQuery] string city, 
                                [FromQuery] DateTime checkIn,
                                [FromQuery] DateTime checkOut)
    {
        var accommodations = await _accommodationRepo.GetAll(c => c.PricePerNight >= priceFrom && c.PricePerNight <= priceTo && c.Location.City.Name == city, false, c => c.AccommodationImages, c => c.AccommodationDetails, c => c.Location);
        var availableAccommodations = new List<Accommodation>();
        foreach (var accommodation in accommodations)
        {
            var reservationsPerAccommodation = await _reservations.GetAll(r => r.AccommodationId == accommodation.Id, false);
            if (reservationsPerAccommodation.Count() == 0 || reservationsPerAccommodation == null)
            {
                availableAccommodations.Add(accommodation);
                continue;
            }
            else if (reservationsPerAccommodation.Any(r => r.StartDate.Date >= checkIn.Date && r.EndDate.Date <= checkOut.Date))
            {
                continue;
            }
            else
            {
                availableAccommodations.Add(accommodation);
            }
        }


        return Ok(_mapper.Map<List<AccommodationGET>>(availableAccommodations));
    }
}
