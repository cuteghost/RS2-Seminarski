using Database;
using Microsoft.Extensions.Logging;
using Microsoft.ML;

namespace Services.RecommendationService;

public class AccommodationRecommendationService
{
    public const string CustomerKeyColumn = "CustomerIdKey";
    public const string AccommodationKeyColumn = "AccommodationIdKey";
    public const int ApproximationRank = 16;

    private readonly MLContext _mlContext;
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<AccommodationRecommendationService> _logger;

    public AccommodationRecommendationService(IServiceProvider serviceProvider, ILogger<AccommodationRecommendationService> logger)
    {
        _mlContext = new MLContext();
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    public async Task<ITransformer> TrainModel(CancellationToken cancellationToken = default)
    {
        using (var scope = _serviceProvider.CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var dataPreparationService = new DataPreparationService(dbContext);

            var trainingData = await dataPreparationService.GetTrainingData();

            cancellationToken.ThrowIfCancellationRequested();

            IDataView dataView = _mlContext.Data.LoadFromEnumerable(trainingData);

            var pipeline = _mlContext.Transforms.Conversion.MapValueToKey(CustomerKeyColumn, "CustomerId")
                .Append(_mlContext.Transforms.Conversion.MapValueToKey(AccommodationKeyColumn, "AccommodationId"))
                .Append(_mlContext.Recommendation().Trainers.MatrixFactorization(
                    labelColumnName: "Rating",
                    matrixColumnIndexColumnName: CustomerKeyColumn,
                    matrixRowIndexColumnName: AccommodationKeyColumn,
                    numberOfIterations: 20,
                    approximationRank: ApproximationRank));

            var model = pipeline.Fit(dataView);
            return model;
        }
    }

    public void SaveModel(ITransformer model, string modelPath)
    {
        try
        {
            var directory = Path.GetDirectoryName(modelPath);
            if (!string.IsNullOrEmpty(directory))
                Directory.CreateDirectory(directory);

            _mlContext.Model.Save(model, null, modelPath);
            _logger.LogInformation("Model preporuka je sačuvan na {Path}.", modelPath);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Model preporuka nije sačuvan na {Path}.", modelPath);
        }
    }
}