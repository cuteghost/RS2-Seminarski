using Microsoft.Extensions.Logging;
using Microsoft.ML;

namespace Services.RecommendationService;

public record AccommodationCandidate(Guid Id, float ReviewScore);

public record RecommendationRanking(List<Guid> AccommodationIds, bool FromModel);

public class RecommendationService
{
    public const float ReviewScoreWeight = 0.1f;

 
    private const float UnknownPairScore = -1_000_000f;

    private readonly MLContext _mlContext;
    private readonly string _modelPath;
    private readonly ILogger<RecommendationService> _logger;
    private ITransformer? _model;

    public RecommendationService(string modelPath, ILogger<RecommendationService> logger)
    {
        _mlContext = new MLContext();
        _modelPath = modelPath;
        _logger = logger;
    }

    private ITransformer? EnsureModelLoaded()
    {
        if (_model != null)
            return _model;

        if (!File.Exists(_modelPath))
        {
            _logger.LogWarning(
                "Recommendation model is not available at {Path} yet; falling back to the review score.", _modelPath);
            return null;
        }

        _model = _mlContext.Model.Load(_modelPath, out _);
        return _model;
    }

    public RecommendationRanking GetRecommendations(Guid customerId, IReadOnlyCollection<AccommodationCandidate> candidates)
    {
        if (candidates.Count == 0)
            return new RecommendationRanking(new List<Guid>(), true);

        var model = EnsureModelLoaded();
        if (model == null)
            return new RecommendationRanking(ByReviewScore(candidates), false);

        using var engine = _mlContext.Model.CreatePredictionEngine<AccommodationRating, AccommodationRatingPrediction>(model);
        var customer = customerId.ToString();

        var ranked = candidates
            .Select(candidate => new
            {
                candidate.Id,
                Score = Score(engine, customer, candidate)
            })
            .OrderByDescending(scored => scored.Score)
            .ThenBy(scored => scored.Id)
            .Select(scored => scored.Id)
            .ToList();

        return new RecommendationRanking(ranked, true);
    }

    private static List<Guid> ByReviewScore(IReadOnlyCollection<AccommodationCandidate> candidates)
    {
        return candidates
            .OrderByDescending(candidate => candidate.ReviewScore)
            .ThenBy(candidate => candidate.Id)
            .Select(candidate => candidate.Id)
            .ToList();
    }

    private static float Score(PredictionEngine<AccommodationRating, AccommodationRatingPrediction> engine,
                               string customerId, AccommodationCandidate candidate)
    {
        var predicted = engine.Predict(new AccommodationRating
        {
            CustomerId = customerId,
            AccommodationId = candidate.Id.ToString()
        }).Score;

        var mlScore = float.IsNaN(predicted) ? UnknownPairScore : predicted;

        return mlScore + ReviewScoreWeight * candidate.ReviewScore;
    }
}
