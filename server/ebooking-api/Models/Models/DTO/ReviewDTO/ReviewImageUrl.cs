namespace Models.DTO.ReviewDTO;

public static class ReviewImageUrl
{
    public static string For(Guid reviewId) => $"/api/Feedback/Image/{reviewId}";
}
