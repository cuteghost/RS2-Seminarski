using API.Exceptions;
using API.Extensions;
using AutoMapper;
using Database.Services.AccommodationCatalogService;
using Database.Services.AccommodationImageService;
using Database.Services.AccommodationWriteService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.Domain;
using Models.DTO.AccommodationDTO;
using Models.DTO.LocationDTO;
using Repository.Interfaces;
using Services.CurrentUserService;
using Services.LocationService;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class AccommodationController : Controller
{
    private const double DefaultNearbyRadiusInKilometers = 10;
    private const int AddressMaxLength = 200;

    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IGenericRepository<Partner> _partnerRepo;
    private readonly IGenericRepository<Reservation> _reservationRepo;
    private readonly IGenericRepository<City> _cityRepo;
    private readonly ICurrentUserService _currentUser;
    private readonly IMapper _mapper;
    private readonly ILocationService _locationService;
    private readonly IAccommodationImageService _imageService;
    private readonly IAccommodationCatalogService _catalog;
    private readonly IAccommodationWriteService _writeService;

    public AccommodationController(IGenericRepository<Accommodation> accommodationRepo, ICurrentUserService currentUser,
                                   IGenericRepository<Partner> partnerRepo, IGenericRepository<Reservation> reservationRepo,
                                   IGenericRepository<City> cityRepo,
                                   IMapper mapper, ILocationService locationService,
                                   IAccommodationImageService imageService,
                                   IAccommodationCatalogService catalog,
                                   IAccommodationWriteService writeService)
    {
        _accommodationRepo = accommodationRepo;
        _partnerRepo = partnerRepo;
        _reservationRepo = reservationRepo;
        _cityRepo = cityRepo;
        _currentUser = currentUser;
        _mapper = mapper;
        _locationService = locationService;
        _imageService = imageService;
        _catalog = catalog;
        _writeService = writeService;
    }

    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> Add([FromBody] AccommodationPOST accommodationDto)
    {
        var partnerId = await _currentUser.GetPartnerIdAsync();
        var partner = await _partnerRepo.Get(c => c.Id == partnerId, false);
        if (partner == null)
            throw new BusinessException("Only a partner can add an accommodation. The logged-in account is not registered as a partner.");

        await _catalog.EnsureTypeExists(accommodationDto.AccommodationTypeId);

        var accommodation = _mapper.Map<Accommodation>(accommodationDto);
        accommodation.Id = Guid.NewGuid();
        accommodation.OwnerId = partner.Id;

        await _accommodationRepo.Add(accommodation);

        if (accommodation.AccommodationDetails != null && accommodationDto.AccommodationDetails != null)
            await _catalog.SetAmenities(accommodation.AccommodationDetails.Id, accommodationDto.AccommodationDetails.AmenityIds);

        var created = await _accommodationRepo.Get(c => c.Id == accommodation.Id, false,
            c => c.AccommodationDetails, c => c.AccommodationType, c => c.Location, c => c.Location.City, c => c.Location.City.Country);

        var addedDto = _mapper.Map<AccommodationGET>(created);
        await _imageService.Attach(new[] { addedDto });
        await _catalog.AttachAmenities(new[] { addedDto });

        return Ok(new BaseResponse<AccommodationGET>("Accommodation added successfully.", addedDto));
    }

    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> Update([FromBody] AccommodationPATCH accommodationDto)
    {
        var partnerId = await _currentUser.GetPartnerIdAsync();

        var existing = await _accommodationRepo.Get(c => c.Id == accommodationDto.Id, false);
        if (existing == null)
            throw new NotFoundException($"Accommodation with identifier {accommodationDto.Id} does not exist.");

        if (existing.OwnerId != partnerId)
            throw new BusinessException("You can only modify an accommodation if you are its owner.");

        await _catalog.EnsureTypeExists(accommodationDto.AccommodationTypeId);

        var accommodation = _mapper.Map<Accommodation>(accommodationDto);

        var images = accommodationDto.AccommodationImages != null
            ? _mapper.Map<AccommodationImages>(accommodationDto.AccommodationImages)
            : null;

        var details = accommodationDto.AccommodationDetails != null
            ? new AccommodationDetailsUpdate(accommodationDto.AccommodationDetails.NumberOfBeds,
                                             accommodationDto.AccommodationDetails.AmenityIds)
            : null;

        var location = await BuildLocationUpdate(accommodationDto.Location);

        await _writeService.Update(accommodation, images, details, location);

        var updated = await _accommodationRepo.Get(c => c.Id == accommodation.Id, false,
            c => c.AccommodationDetails, c => c.AccommodationType, c => c.Location, c => c.Location.City, c => c.Location.City.Country);

        var updatedDto = _mapper.Map<AccommodationGET>(updated);
        await _imageService.Attach(new[] { updatedDto });
        await _catalog.AttachAmenities(new[] { updatedDto });

        return Ok(new BaseResponse<AccommodationGET>("Accommodation updated successfully.", updatedDto));
    }

    /// <summary>
    /// Adresa i njene koordinate stižu samo kada ih klijent zaista mijenja. Grad se provjerava
    /// ovdje jer je strani ključ lokacije, pa bi nepostojeći identifikator inače pao tek u bazi.
    /// </summary>
    private async Task<AccommodationLocationUpdate?> BuildLocationUpdate(LocationPATCH? locationDto)
    {
        if (locationDto == null)
            return null;

        var address = locationDto.Address?.Trim() ?? string.Empty;

        if (address.Length == 0)
            throw new BusinessException("Accommodation address is required and must not be blank.");

        if (address.Length > AddressMaxLength)
            throw new BusinessException($"Accommodation address must not exceed {AddressMaxLength} characters.");

        if (locationDto.Latitude < -90 || locationDto.Latitude > 90)
            throw new BusinessException("Latitude must be between -90 and 90.");

        if (locationDto.Longitude < -180 || locationDto.Longitude > 180)
            throw new BusinessException("Longitude must be between -180 and 180.");

        var city = await _cityRepo.Get(c => c.Id == locationDto.CityId, false);
        if (city == null)
            throw new NotFoundException($"City with identifier {locationDto.CityId} does not exist.");

        return new AccommodationLocationUpdate(address, locationDto.Latitude, locationDto.Longitude, locationDto.CityId);
    }

    /// <summary>
    /// Meko brisanje. Rezervacije iz prošlosti ne blokiraju brisanje i ostaju vezane za meko
    /// obrisan zapis.
    /// </summary>
    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> Delete([FromRoute] Guid id)
    {
        var accommodation = await _accommodationRepo.Get(c => c.Id == id, false);
        if (accommodation == null)
            throw new NotFoundException($"Accommodation with identifier {id} does not exist.");

        if (_currentUser.Role != Roles.Administrator)
        {
            var partnerId = await _currentUser.GetPartnerIdAsync();
            if (partnerId == Guid.Empty || accommodation.OwnerId != partnerId)
                throw new BusinessException("Only its owner or an administrator can delete an accommodation.");
        }

        var today = DateTime.UtcNow.Date;
        var activeReservations = await _reservationRepo.Count(r => r.AccommodationId == id && r.EndDate >= today);
        if (activeReservations > 0)
            throw new BusinessException(
                $"Accommodation \"{accommodation.Name}\" cannot be deleted because it has reservations that are ongoing or upcoming (total: {activeReservations}).");

        await _accommodationRepo.Delete(c => c.Id == id);

        return Ok(new BaseResponse<object>("Accommodation deleted successfully.", null));
    }

    /// <summary>
    /// Mijenja samo status smještaja. Vlasnik ili administrator; postavljanje već postojećeg
    /// stanja ne mijenja ništa i ne baca grešku.
    /// </summary>
    [HttpPatch]
    [Route("Status/{id}")]
    public async Task<IActionResult> SetStatus([FromRoute] Guid id, [FromQuery] bool status)
    {
        var accommodation = await _accommodationRepo.Get(c => c.Id == id, false);
        if (accommodation == null)
            throw new NotFoundException($"Accommodation with identifier {id} does not exist.");

        if (_currentUser.Role != Roles.Administrator)
        {
            var partnerId = await _currentUser.GetPartnerIdAsync();
            if (partnerId == Guid.Empty || accommodation.OwnerId != partnerId)
                throw new BusinessException("Only its owner or an administrator can change the accommodation's status.");
        }

        await _writeService.SetStatus(id, status);

        var updated = await _accommodationRepo.Get(c => c.Id == id, false,
            c => c.AccommodationDetails, c => c.AccommodationType, c => c.Location, c => c.Location.City, c => c.Location.City.Country);

        var updatedDto = _mapper.Map<AccommodationGET>(updated);
        await _imageService.Attach(new[] { updatedDto });
        await _catalog.AttachAmenities(new[] { updatedDto });

        var message = status
            ? $"Accommodation \"{updated.Name}\" has been activated."
            : $"Accommodation \"{updated.Name}\" has been deactivated.";

        return Ok(new BaseResponse<AccommodationGET>(message, updatedDto));
    }

    [HttpGet]
    [Route("GetAccommodations")]
    public async Task<IActionResult> GetAccommodations([FromQuery] int page = 1, [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var (items, totalCount) = await _accommodationRepo.GetPaged(page, pageSize, false,
            c => c.AccommodationDetails, c => c.AccommodationType, c => c.Location, c => c.Location.City, c => c.Location.City.Country);
        var accommodations = _mapper.Map<List<AccommodationGET>>(items);
        await _imageService.Attach(accommodations);
        await _catalog.AttachAmenities(accommodations);

        return Ok(new PagedResponse<AccommodationGET>("Accommodations retrieved successfully.", accommodations, page, pageSize, totalCount));
    }

    [HttpGet]
    [Route("GetMyAccommodation")]
    public async Task<IActionResult> GetMyAccommodation([FromQuery] int page = 1, [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        var partnerId = await _currentUser.GetPartnerIdAsync();
        if (partnerId == Guid.Empty)
            throw new BusinessException("The logged-in account is not registered as a partner, so it has no accommodations.");

        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var (items, totalCount) = await _accommodationRepo.GetPaged(c => c.OwnerId == partnerId, page, pageSize, false,
            c => c.AccommodationDetails, c => c.AccommodationType, c => c.Location, c => c.Location.City, c => c.Location.City.Country);
        var accommodations = _mapper.Map<List<AccommodationGET>>(items);
        await _imageService.Attach(accommodations);
        await _catalog.AttachAmenities(accommodations);

        return Ok(new PagedResponse<AccommodationGET>("Your accommodations retrieved successfully.", accommodations, page, pageSize, totalCount));
    }

    [HttpGet]
    [Route("GetAccommodationById")]
    public async Task<IActionResult> GetAccommodationById([FromQuery] Guid id)
    {
        var rawAccommodation = await _accommodationRepo.Get(c => c.Id == id, false,
            c => c.AccommodationDetails, c => c.AccommodationType, c => c.Location, c => c.Location.City, c => c.Location.City.Country, c => c.Owner.User);
        if (rawAccommodation == null)
            throw new NotFoundException($"Accommodation with identifier {id} does not exist.");

        var accommodation = _mapper.Map<AccommodationGET>(rawAccommodation);
        accommodation.OwnerId = rawAccommodation.Owner.User.Id;
        await _imageService.Attach(new[] { accommodation });
        await _catalog.AttachAmenities(new[] { accommodation });

        return Ok(new BaseResponse<AccommodationGET>("Accommodation retrieved successfully.", accommodation));
    }

    [HttpGet]
    [Route("GetNearby")]
    public async Task<IActionResult> GetNearby([FromQuery] double latitude,
                                               [FromQuery] double longitude,
                                               [FromQuery] double radius = DefaultNearbyRadiusInKilometers,
                                               [FromQuery] int page = 1,
                                               [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        if (radius <= 0)
            throw new BusinessException("The search radius must be greater than zero and is expressed in kilometers.");

        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var nearby = _locationService.WithinRadius(latitude, longitude, radius).And(c => c.Status);
        var proximityScore = _locationService.ProximityScore(latitude, longitude);

        var (items, totalCount) = await _accommodationRepo.GetPaged(
            nearby, proximityScore, true, page, pageSize, false,
            c => c.Location, c => c.Location.City, c => c.Location.City.Country, c => c.AccommodationDetails);
        var accommodations = _mapper.Map<List<AccommodationGET>>(items);
        await _imageService.Attach(accommodations);
        await _catalog.AttachAmenities(accommodations);

        return Ok(new PagedResponse<AccommodationGET>("Nearby accommodations retrieved successfully.", accommodations, page, pageSize, totalCount));
    }
}
