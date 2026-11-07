using API.Exceptions;
using Database.Services.ImageValidation;
using Models.Domain;

namespace Database.Services.AccommodationImageService;

public static class AccommodationImageRules
{
    public const int RequiredImageCount = 5;

    public static void EnsureValid(AccommodationImages images)
    {
        var slots = new[]
        {
            images.Image1, images.Image2, images.Image3, images.Image4, images.Image5,
            images.Image6, images.Image7, images.Image8, images.Image9, images.Image10,
            images.Image11, images.Image12, images.Image13, images.Image14, images.Image15,
            images.Image16, images.Image17, images.Image18, images.Image19, images.Image20
        };

        if (slots.Take(RequiredImageCount).Any(image => image == null || image.Length == 0))
            throw new BusinessException(
                $"Accommodation must have the first {RequiredImageCount} images filled in. Send images 1 to {RequiredImageCount}; the remaining 15 slots are optional.");

        for (var i = 0; i < slots.Length; i++)
            ImageContentValidator.EnsureValid(slots[i], $"Image {i + 1}");
    }
}
