using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Services.RecommendationService;

public class RecommendationModelHostedService : BackgroundService
{
    private readonly AccommodationRecommendationService _trainer;
    private readonly ILogger<RecommendationModelHostedService> _logger;
    private readonly string _modelPath;

    public RecommendationModelHostedService(AccommodationRecommendationService trainer,
                                            ILogger<RecommendationModelHostedService> logger)
    {
        _trainer = trainer;
        _logger = logger;
        _modelPath = Path.Combine(Directory.GetCurrentDirectory(), "MLModels", "MLmodel.zip");
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await Task.Yield();

        try
        {
            if (File.Exists(_modelPath))
            {
                _logger.LogInformation(
                    "Recommendation model already present at {Path}; skipping startup training.", _modelPath);
                return;
            }

            _logger.LogInformation(
                "No recommendation model found at {Path}; training a new model in the background.", _modelPath);
            var model = await _trainer.TrainModel(stoppingToken);
            _trainer.SaveModel(model, _modelPath);
            _logger.LogInformation("Recommendation model trained and saved to {Path}.", _modelPath);
        }
        catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
        {
            _logger.LogInformation("Background training of the recommendation model was cancelled on shutdown.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Background training of the recommendation model failed.");
        }
    }
}
