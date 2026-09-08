using API.Exceptions;
using AutoMapper;
using Authentication.Services.TokenHandlerService;
using Database.Services.ProfileService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.Domain;
using Models.DTO.AuthDTO;
using Models.DTO.UserDTO.Partner;
using Repository.Interfaces;
using Services.CurrentUserService;

namespace API.Controllers.UserControllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class PartnerController : Controller
{
    private const long TaxIdMinimum = 100_000_000_000;
    private const long TaxIdMaximum = 9_999_999_999_999;
    private const long PhoneNumberMinimum = 38_700_000_000;
    private const long PhoneNumberMaximum = 38_799_999_999;

    private readonly IGenericRepository<Partner> _partnerRepo;
    private readonly IMapper _mapper;
    private readonly ICurrentUserService _currentUser;
    private readonly ITokenHandlerService _tokenHandler;
    private readonly IUserRepository _userRepository;
    private readonly IProfileService _profileService;
    private readonly IGenericRepository<Country> _countryRepo;

    public PartnerController(IGenericRepository<Partner> partnerRepo, IMapper mapper, ICurrentUserService currentUser,
                             ITokenHandlerService tokenHandler, IUserRepository userRepository,
                             IProfileService profileService, IGenericRepository<Country> countryRepo)
    {
        _currentUser = currentUser;
        _tokenHandler = tokenHandler;
        _partnerRepo = partnerRepo;
        _mapper = mapper;
        _userRepository = userRepository;
        _profileService = profileService;
        _countryRepo = countryRepo;
    }

    [HttpPost]
    [Route("Add")]
    public async Task<IActionResult> RegisterAsPartner([FromBody] PartnerPOST userDto)
    {
        var userId = _currentUser.UserId;

        if (await _partnerRepo.Get(p => p.UserId == userId, false) != null)
            throw new BusinessException("The logged-in account is already registered as a partner.");

        userDto.TaxName = (userDto.TaxName ?? string.Empty).Trim();

        if (userDto.TaxName.Length == 0)
            throw new BusinessException("Tax name is required.");

        if (userDto.TaxId < TaxIdMinimum || userDto.TaxId > TaxIdMaximum)
            throw new BusinessException("Tax ID must have 12 or 13 digits, without spaces or other characters.");

        if (userDto.PhoneNumber < PhoneNumberMinimum || userDto.PhoneNumber > PhoneNumberMaximum)
            throw new BusinessException("Phone number must be in the format 0038762730854: 00387 followed by eight digits.");

        if (!await _countryRepo.Any(c => c.Id == userDto.CountryId))
            throw new NotFoundException($"Country with identifier {userDto.CountryId} does not exist.");

        var partner = _mapper.Map<Partner>(userDto);
        partner.Id = Guid.NewGuid();
        partner.UserId = userId;

        if (!await _partnerRepo.Add(partner))
            throw new BusinessException("The partner was not created. Please check the entered data and try again.");

        var userWithUpdatedRole = await _userRepository.UpdateRole(Role.PartnerRole, userId);
        if (userWithUpdatedRole == null)
            throw new NotFoundException("The logged-in account no longer exists.");

        // Novi token je obavezan: stari nosi ulogu Customer pa partnerski ekrani ne bi radili.
        var token = await _tokenHandler.CreateTokenAsync(userWithUpdatedRole);

        return Ok(new BaseResponse<TokenResponse>("Account registered successfully as a partner.", new TokenResponse { Token = token }));
    }

    [HttpGet]
    [Route("PartnerDetails")]
    public async Task<IActionResult> GetPartnerDetails()
    {
        var userId = _currentUser.UserId;

        var partner = await _partnerRepo.Get(c => c.UserId == userId, false, c => c.User);
        if (partner == null)
            throw new NotFoundException("The logged-in account is not registered as a partner.");

        return Ok(new BaseResponse<PartnerGET>("Partner data retrieved successfully.", _mapper.Map<PartnerGET>(partner)));
    }

    /// <summary>
    /// Brisanje partnera po tudem identifikatoru. Ranije je bilo dostupno svakom prijavljenom
    /// korisniku, pa je bilo koji nalog mogao obrisati bilo kojeg partnera.
    /// </summary>
    [Authorize(Roles = Roles.Administrator)]
    [HttpDelete]
    [Route("Delete/{id}")]
    public async Task<IActionResult> Delete([FromRoute] Guid id)
    {
        if (!await _partnerRepo.Delete(u => u.User.Id == id))
            throw new NotFoundException($"A partner for the user with identifier {id} does not exist.");

        return Ok(new BaseResponse<object>("Partner deleted successfully.", null));
    }

    [HttpPatch]
    [Route("Update")]
    public async Task<IActionResult> UpdateUser([FromBody] PartnerPATCH partnerDto)
    {
        var validPartnerId = await _currentUser.GetPartnerIdAsync();
        if (validPartnerId == Guid.Empty)
            throw new NotFoundException("The logged-in account is not registered as a partner.");

        await _profileService.UpdatePartnerProfile(_currentUser.UserId, validPartnerId, partnerDto);

        var updated = await _partnerRepo.Get(c => c.Id == validPartnerId, false, c => c.User);

        return Ok(new BaseResponse<PartnerGET>("Partner data updated successfully.", _mapper.Map<PartnerGET>(updated)));
    }
}
