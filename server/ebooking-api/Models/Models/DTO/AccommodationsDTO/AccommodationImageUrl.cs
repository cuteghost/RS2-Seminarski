namespace Models.DTO.AccommodationDTO;

public static class AccommodationImageUrl
{
    public const int MaxImages = 20;

    public static string For(Guid accommodationId, int index) =>
        $"/api/AccommodationImage/{accommodationId}/{index}";
}
