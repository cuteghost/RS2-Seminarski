using API.Exceptions;

namespace Database.Services.AccommodationWriteService;

public static class AccommodationRules
{
    public const int NameMinLength = 3;
    public const int NameMaxLength = 50;
    public const int DescriptionMinLength = 50;
    public const int DescriptionMaxLength = 1000;
    public const double MaxPricePerNight = 100000;
    public const int MinBeds = 1;
    public const int MaxBeds = 50;
    public const int AddressMaxLength = 200;

    public static AccommodationInput Normalize(AccommodationInput input)
    {
        var name = input.Name?.Trim() ?? string.Empty;
        if (name.Length < NameMinLength || name.Length > NameMaxLength)
            throw new BusinessException($"Accommodation name must have between {NameMinLength} and {NameMaxLength} characters.");

        var description = input.Description?.Trim() ?? string.Empty;
        if (description.Length < DescriptionMinLength || description.Length > DescriptionMaxLength)
            throw new BusinessException($"Accommodation description must have between {DescriptionMinLength} and {DescriptionMaxLength} characters.");

        if (double.IsNaN(input.PricePerNight) || input.PricePerNight <= 0 || input.PricePerNight > MaxPricePerNight)
            throw new BusinessException($"Price per night must be greater than 0 and at most {MaxPricePerNight}.");

        if (input.AccommodationTypeId == Guid.Empty)
            throw new BusinessException("Accommodation type is required.");

        return input with { Name = name, Description = description, PricePerNight = Math.Round(input.PricePerNight, 2) };
    }

    public static AccommodationDetailsUpdate Normalize(AccommodationDetailsUpdate details)
    {
        if (details.NumberOfBeds < MinBeds || details.NumberOfBeds > MaxBeds)
            throw new BusinessException($"Number of beds must be between {MinBeds} and {MaxBeds}.");

        var amenityIds = (details.AmenityIds ?? Array.Empty<Guid>()).Where(id => id != Guid.Empty).Distinct().ToList();

        return details with { AmenityIds = amenityIds };
    }

    public static AccommodationLocationUpdate Normalize(AccommodationLocationUpdate location)
    {
        var address = location.Address?.Trim() ?? string.Empty;

        if (address.Length == 0)
            throw new BusinessException("Accommodation address is required and must not be blank.");

        if (address.Length > AddressMaxLength)
            throw new BusinessException($"Accommodation address must not exceed {AddressMaxLength} characters.");

        if (double.IsNaN(location.Latitude) || location.Latitude < -90 || location.Latitude > 90)
            throw new BusinessException("Latitude must be between -90 and 90.");

        if (double.IsNaN(location.Longitude) || location.Longitude < -180 || location.Longitude > 180)
            throw new BusinessException("Longitude must be between -180 and 180.");

        if (location.CityId == Guid.Empty)
            throw new BusinessException("City is required.");

        return location with { Address = address };
    }
}
