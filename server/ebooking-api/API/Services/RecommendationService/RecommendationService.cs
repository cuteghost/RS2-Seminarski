using Microsoft.Extensions.Logging;
using Microsoft.ML;

namespace Services.RecommendationService;

public record AccommodationCandidate(
    Guid Id,
    float ReviewScore,
    Guid? CityId,
    string CityName,
    Guid AccommodationTypeId,
    string TypeName,
    double PricePerNight,
    double? Latitude,
    double? Longitude,
    IReadOnlyCollection<Guid> AmenityIds);

public record CustomerProfile(
    IReadOnlySet<Guid> StayedAccommodationIds,
    IReadOnlySet<Guid> VisitedCityIds,
    IReadOnlyDictionary<Guid, int> AmenityFrequency,
    double? Latitude,
    double? Longitude);

public record ScoredRecommendation(Guid AccommodationId, double Score, List<string> Reasons);

public record RecommendationRanking(List<ScoredRecommendation> Items, bool FromModel);

public class RecommendationService
{
    public const double ReviewScoreWeight = 0.1;
    public const double VisitedCityBoost = 1.5;
    public const double AmenityAffinityWeight = 2.0;
    public const double NearbyBoost = 1.0;
    public const double NearbyRadiusKm = 20;
    public const double StrongPredictionThreshold = 6;
    public const double HighRatingThreshold = 8;

    public const double SimilarCityBoost = 2.0;
    public const double SimilarTypeBoost = 1.0;
    public const double SimilarAmenityWeight = 2.0;
    public const double SimilarPriceWeight = 1.0;
    public const double PersonalizationWeight = 0.2;

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
                "Recommendation model is not available at {Path} yet; ranking uses the content signals only.", _modelPath);
            return null;
        }

        _model = _mlContext.Model.Load(_modelPath, out _);
        return _model;
    }

    public RecommendationRanking GetRecommendations(Guid customerId,
                                                    CustomerProfile profile,
                                                    IReadOnlyCollection<AccommodationCandidate> candidates,
                                                    IReadOnlyDictionary<Guid, string> amenityNames)
    {
        if (candidates.Count == 0)
            return new RecommendationRanking(new List<ScoredRecommendation>(), true);

        var model = EnsureModelLoaded();
        using var engine = model != null
            ? _mlContext.Model.CreatePredictionEngine<AccommodationRating, AccommodationRatingPrediction>(model)
            : null;

        var customer = customerId.ToString();
        var totalAmenityWeight = profile.AmenityFrequency.Values.Sum();

        var scored = candidates
            .Where(candidate => !profile.StayedAccommodationIds.Contains(candidate.Id))
            .Select(candidate =>
            {
                var contributions = new List<(double Weight, string Reason)>();
                var score = 0.0;

                var predicted = Predict(engine, customer, candidate.Id);
                if (predicted.HasValue)
                {
                    score += predicted.Value;
                    if (predicted.Value >= StrongPredictionThreshold)
                        contributions.Add((predicted.Value, $"Guests with stays similar to yours rated it highly (predicted {predicted.Value:0.0}/10)"));
                }

                if (candidate.CityId.HasValue && profile.VisitedCityIds.Contains(candidate.CityId.Value))
                {
                    score += VisitedCityBoost;
                    contributions.Add((VisitedCityBoost, $"In {candidate.CityName}, where you have stayed before"));
                }

                if (totalAmenityWeight > 0 && candidate.AmenityIds.Count > 0)
                {
                    var shared = candidate.AmenityIds
                        .Where(profile.AmenityFrequency.ContainsKey)
                        .OrderByDescending(id => profile.AmenityFrequency[id])
                        .ToList();

                    var affinity = shared.Sum(id => profile.AmenityFrequency[id]) / (double)totalAmenityWeight;
                    if (affinity > 0)
                    {
                        var weight = AmenityAffinityWeight * affinity;
                        score += weight;

                        var names = shared.Take(3).Select(id => amenityNames.TryGetValue(id, out var name) ? name : null)
                            .Where(name => name != null).ToList();
                        if (names.Count > 0)
                            contributions.Add((weight, $"Offers {string.Join(", ", names)}, like the places you booked"));
                    }
                }

                var distance = DistanceKm(profile.Latitude, profile.Longitude, candidate.Latitude, candidate.Longitude);
                if (distance.HasValue && distance.Value <= NearbyRadiusKm)
                {
                    var weight = NearbyBoost * (1 - distance.Value / NearbyRadiusKm);
                    score += weight;
                    contributions.Add((weight, $"{distance.Value:0.0} km from your current location"));
                }

                score += ReviewScoreWeight * candidate.ReviewScore;
                if (candidate.ReviewScore >= HighRatingThreshold)
                    contributions.Add((ReviewScoreWeight * candidate.ReviewScore, $"Highly rated by guests ({candidate.ReviewScore:0.0}/10)"));

                return new ScoredRecommendation(candidate.Id, score, OrderedReasons(contributions, candidate));
            })
            .OrderByDescending(item => item.Score)
            .ThenBy(item => item.AccommodationId)
            .ToList();

        return new RecommendationRanking(scored, model != null);
    }

    public RecommendationRanking GetSimilar(Guid customerId,
                                            AccommodationCandidate source,
                                            IReadOnlyCollection<AccommodationCandidate> candidates,
                                            IReadOnlyDictionary<Guid, string> amenityNames)
    {
        var model = EnsureModelLoaded();
        using var engine = model != null
            ? _mlContext.Model.CreatePredictionEngine<AccommodationRating, AccommodationRatingPrediction>(model)
            : null;

        var customer = customerId.ToString();
        var sourceAmenities = source.AmenityIds.ToHashSet();

        var scored = candidates
            .Where(candidate => candidate.Id != source.Id)
            .Select(candidate =>
            {
                var contributions = new List<(double Weight, string Reason)>();
                var score = 0.0;

                if (source.CityId.HasValue && candidate.CityId == source.CityId)
                {
                    score += SimilarCityBoost;
                    contributions.Add((SimilarCityBoost, $"Also in {candidate.CityName}"));
                }

                if (candidate.AccommodationTypeId == source.AccommodationTypeId)
                {
                    score += SimilarTypeBoost;
                    contributions.Add((SimilarTypeBoost, $"Also a {candidate.TypeName.ToLowerInvariant()}"));
                }

                if (sourceAmenities.Count > 0 && candidate.AmenityIds.Count > 0)
                {
                    var shared = candidate.AmenityIds.Where(sourceAmenities.Contains).ToList();
                    var union = sourceAmenities.Union(candidate.AmenityIds).Count();
                    var jaccard = union == 0 ? 0 : shared.Count / (double)union;
                    if (jaccard > 0)
                    {
                        var weight = SimilarAmenityWeight * jaccard;
                        score += weight;

                        var names = shared.Take(3).Select(id => amenityNames.TryGetValue(id, out var name) ? name : null)
                            .Where(name => name != null).ToList();
                        if (names.Count > 0)
                            contributions.Add((weight, $"Shares {shared.Count} amenities, e.g. {string.Join(", ", names)}"));
                    }
                }

                if (source.PricePerNight > 0)
                {
                    var closeness = 1 - Math.Min(1, Math.Abs(candidate.PricePerNight - source.PricePerNight) / source.PricePerNight);
                    if (closeness > 0.6)
                    {
                        var weight = SimilarPriceWeight * closeness;
                        score += weight;
                        contributions.Add((weight, $"Similar price ({candidate.PricePerNight:0.##} per night)"));
                    }
                }

                var predicted = Predict(engine, customer, candidate.Id);
                if (predicted.HasValue)
                {
                    var weight = PersonalizationWeight * predicted.Value;
                    score += weight;
                    if (predicted.Value >= StrongPredictionThreshold)
                        contributions.Add((weight, $"Matches your past stays (predicted {predicted.Value:0.0}/10)"));
                }

                score += ReviewScoreWeight * candidate.ReviewScore;

                return new ScoredRecommendation(candidate.Id, score, OrderedReasons(contributions, candidate));
            })
            .OrderByDescending(item => item.Score)
            .ThenBy(item => item.AccommodationId)
            .ToList();

        return new RecommendationRanking(scored, model != null);
    }

    private static List<string> OrderedReasons(List<(double Weight, string Reason)> contributions, AccommodationCandidate candidate)
    {
        var reasons = contributions
            .OrderByDescending(c => c.Weight)
            .Select(c => c.Reason)
            .ToList();

        if (reasons.Count == 0)
            reasons.Add(candidate.ReviewScore > 0
                ? $"Popular with guests ({candidate.ReviewScore:0.0}/10)"
                : "A new place you have not tried yet");

        return reasons;
    }

    private static double? Predict(PredictionEngine<AccommodationRating, AccommodationRatingPrediction>? engine,
                                   string customerId, Guid accommodationId)
    {
        if (engine == null)
            return null;

        var predicted = engine.Predict(new AccommodationRating
        {
            CustomerId = customerId,
            AccommodationId = accommodationId.ToString()
        }).Score;

        return float.IsNaN(predicted) || float.IsInfinity(predicted) ? null : Math.Clamp(predicted, 1f, 10f);
    }

    private static double? DistanceKm(double? lat1, double? lon1, double? lat2, double? lon2)
    {
        if (!lat1.HasValue || !lon1.HasValue || !lat2.HasValue || !lon2.HasValue)
            return null;

        const double earthRadiusKm = 6371;
        var dLat = ToRadians(lat2.Value - lat1.Value);
        var dLon = ToRadians(lon2.Value - lon1.Value);
        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(ToRadians(lat1.Value)) * Math.Cos(ToRadians(lat2.Value)) *
                Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

        return earthRadiusKm * 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
    }

    private static double ToRadians(double degrees) => degrees * Math.PI / 180;
}
