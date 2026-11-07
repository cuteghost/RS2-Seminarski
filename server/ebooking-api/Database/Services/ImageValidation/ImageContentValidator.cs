using API.Exceptions;

namespace Database.Services.ImageValidation;

public static class ImageContentValidator
{
    public const int MaxImageBytes = 5 * 1024 * 1024;

    private static readonly byte[] JpegSignature = { 0xFF, 0xD8, 0xFF };
    private static readonly byte[] PngSignature = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A };

    public static void EnsureValid(byte[]? content, string field)
    {
        if (content == null || content.Length == 0)
            return;

        if (content.Length > MaxImageBytes)
            throw new BusinessException($"{field} is larger than the allowed {MaxImageBytes / (1024 * 1024)} MB.");

        if (!StartsWith(content, JpegSignature) && !StartsWith(content, PngSignature))
            throw new BusinessException($"{field} is not a valid image. Only JPEG and PNG files are allowed.");
    }

    public static void EnsureValid(IEnumerable<(byte[]? Content, string Field)> images)
    {
        foreach (var (content, field) in images)
            EnsureValid(content, field);
    }

    private static bool StartsWith(byte[] content, byte[] signature)
    {
        if (content.Length < signature.Length)
            return false;

        for (var i = 0; i < signature.Length; i++)
        {
            if (content[i] != signature[i])
                return false;
        }

        return true;
    }
}
