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

    private readonly IGenericRepository<Accommodation> _accommodationRepo;
    private readonly IGenericRepository<Partner> _partnerRepo;
    private readonly IGenericRepository<Reservation> _reservationRepo;
    private readonly ICurrentUserService _currentUser;
    private readonly IMapper _mapper;
    private readonly ILocationService _locationService;
    private readonly IAccommodationImageService _imageService;
    private readonly IAccommodationCatalogService _catalog;
    private readonly IAccommodationWriteService _writeService;

    public AccommodationController(IGenericRepository<Accommodation> accommodationRepo, ICurrentUserService currentUser,
                                   IGenericRepository<Partner> partnerRepo, IGenericRepository<Reservation> reservationRepo,
                                   IMapper mapper, ILocationService locationService,
                                   IAccommodationImageService imageService,
                                   IAccommodationCatalogService catalog,
                                   IAccommodationWriteService writeService)
    {
        _accommodationRepo = accommodationRepo;
        _partnerRepo = partnerRepo;
        _reservationRepo = reservationRepo;
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
        if (partnerId == Guid.Empty || !await _partnerRepo.Any(p => p.Id == partnerId))
            throw new BusinessException("Only a partner can add an accommodation. The logged-in account is not registered as a partner.");

        var input = new AccommodationInput(accommodationDto.Name, accommodationDto.Description,
                                           accommodationDto.PricePerNight, accommodationDto.AccommodationTypeId);

        var details = accommodationDto.AccommodationDetails != null
            ? new AccommodationDetailsUpdate(accommodationDto.AccommodationDetails.NumberOfBeds,
                                             accommodationDto.AccommodationDetails.AmenityIds)
            : null;

        var location = accommodationDto.Location != null
            ? new AccommodationLocationUpdate(accommodationDto.Location.Address, accommodationDto.Location.Latitude,
                                              accommodationDto.Location.Longitude, accommodationDto.Location.CityId)
            : null;

        var images = accommodationDto.AccommodationImages != null
            ? _mapper.Map<AccommodationImages>(accommodationDto.AccommodationImages)
            : null;

        var id = await _writeService.Create(partnerId, input, details, location, images);

        return Ok(new BaseResponse<AccommodationGET>("Accommodation added successfully.", await LoadDto(id)));
    }

    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> Update([FromBody] AccommodationPATCH accommodationDto)
    {
        var partnerId = await _currentUser.GetPartnerIdAsync();

        var existing = await _accommodationRepo.Get(c => c.Id == accommodationDto.Id, false);
        if (existing == null)
            throw new NotFoundException($"Accommodation with identifier {accommodationDto.Id} does not exist.");

        if (partnerId == Guid.Empty || existing.OwnerId != partnerId)
            throw new BusinessException("You can only modify an accommodation if you are its owner.");

        var input = new AccommodationInput(accommodationDto.Name, accommodationDto.Description,
                                           accommodationDto.PricePerNight, accommodationDto.AccommodationTypeId);

        var images = accommodationDto.AccommodationImages != null
            ? _mapper.Map<AccommodationImages>(accommodationDto.AccommodationImages)
            : null;

        var details = accommodationDto.AccommodationDetails != null
            ? new AccommodationDetailsUpdate(accommodationDto.AccommodationDetails.NumberOfBeds,
                                             accommodationDto.AccommodationDetails.AmenityIds)
            : null;

        var location = accommodationDto.Location != null
            ? new AccommodationLocationUpdate(accommodationDto.Location.Address, accommodationDto.Location.Latitude,
                                              accommodationDto.Location.Longitude, accommodationDto.Location.CityId)
            : null;

        await _writeService.Update(accommodationDto.Id, input, images, details, location);

        return Ok(new BaseResponse<AccommodationGET>("Accommodation updated successfully.", await LoadDto(accommodationDto.Id)));
    }

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

        var activeReservations = await _reservationRepo.Count(ReservationPolicy.HoldsTerm(id, DateTime.UtcNow));
        if (activeReservations > 0)
            throw new BusinessException(
                $"Accommodation \"{accommodation.Name}\" cannot be deleted because it has pending or confirmed reservations that are ongoing or upcoming (total: {activeReservations}).");

        await _accommodationRepo.Delete(c => c.Id == id);

        return Ok(new BaseResponse<object>("Accommodation deleted successfully.", null));
    }

    [Authorize(Roles = Roles.Administrator)]
    [HttpPatch]
    [Route("Promote/{id}")]
    public async Task<IActionResult> SetPromoted([FromRoute] Guid id, [FromQuery] bool promoted)
    {
        await _writeService.SetPromoted(id, promoted);

        var updated = await LoadDto(id);
        var message = promoted
            ? $"Accommodation \"{updated.Name}\" is now promoted."
            : $"Accommodation \"{updated.Name}\" is no longer promoted.";

        return Ok(new BaseResponse<AccommodationGET>(message, updated));
    }

    [HttpGet]
    [Route("GetPromoted")]
    public async Task<IActionResult> GetPromoted([FromQuery] int page = 1, [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var (items, totalCount) = await _accommodationRepo.GetPaged(
            c => c.IsPromoted && c.Status, c => c.PromotedAt, true, page, pageSize, false,
            c => c.AccommodationDetails, c => c.AccommodationType, c => c.Location, c => c.Location.City, c => c.Location.City.Country);

        var accommodations = _mapper.Map<List<AccommodationGET>>(items);
        await _imageService.Attach(accommodations);
        await _catalog.AttachAmenities(accommodations);

        return Ok(new PagedResponse<AccommodationGET>("Promoted accommodations retrieved successfully.", accommodations, page, pageSize, totalCount));
    }

    private async Task<AccommodationGET> LoadDto(Guid id)
    {
        var entity = await _accommodationRepo.Get(c => c.Id == id, false,
            c => c.AccommodationDetails, c => c.AccommodationType, c => c.Location, c => c.Location.City, c => c.Location.City.Country);
        if (entity == null)
            throw new NotFoundException($"Accommodation with identifier {id} does not exist.");

        var dto = _mapper.Map<AccommodationGET>(entity);
        await _imageService.Attach(new[] { dto });
        await _catalog.AttachAmenities(new[] { dto });

        return dto;
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

        var updatedDto = await LoadDto(id);

        var message = status
            ? $"Accommodation \"{updatedDto.Name}\" has been activated."
            : $"Accommodation \"{updatedDto.Name}\" has been deactivated.";

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
