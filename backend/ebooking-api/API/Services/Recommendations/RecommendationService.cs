using Microsoft.ML;
using Models.Domain;

namespace Services.Recommendations;
public class RecommendationService
{
    private readonly MLContext _mlContext;
    private readonly ITransformer _model;

    public RecommendationService(string modelPath)
    {
        _mlContext = new MLContext();
        _model = LoadModel(modelPath);
    }

    private ITransformer LoadModel(string modelPath)
    {
        return _mlContext.Model.Load(modelPath, out var modelInputSchema);
    }

    public float Predict(Guid customerId, Guid accommodationId, float pricePerNight, float reviewScore)
    {
        var predictionEngine = _mlContext.Model.CreatePredictionEngine<AccommodationRating, AccommodationRatingPrediction>(_model);

        var input = new AccommodationRating
        {
            CustomerId = GuidToFloat(customerId),
            AccommodationId = GuidToFloat(accommodationId),
            PricePerNight = pricePerNight,
            ReviewScore = reviewScore
        };

        var prediction = predictionEngine.Predict(input);
        return prediction.Score;
    }

    public List<Guid> GetRecommendations(Guid customerId, List<Accommodation> accommodations)
    {
        var recommendations = accommodations.Select(a => new
        {
            Accommodation = a,
            Score = Predict(customerId, a.Id, (float)a.PricePerNight, a.ReviewScore)
        })
        .OrderByDescending(r => r.Score)
        .Select(r => r.Accommodation.Id)
        .ToList();

        return recommendations;
    }

    private float GuidToFloat(Guid guid)
    {
        var bytes = guid.ToByteArray();
        int intValue = BitConverter.ToInt32(bytes, 0);
        return intValue;
    }
}
