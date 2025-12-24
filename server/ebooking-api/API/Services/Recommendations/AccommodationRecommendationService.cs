using Database;
using Microsoft.ML;

namespace Services.Recommendations;

public class AccommodationRecommendationService
{
    private readonly MLContext _mlContext;
    private readonly IServiceProvider _serviceProvider;

    public AccommodationRecommendationService(IServiceProvider serviceProvider)
    {
        _mlContext = new MLContext();
        _serviceProvider = serviceProvider;
    }

    public ITransformer TrainModel()
    {
        using (var scope = _serviceProvider.CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var dataPreparationService = new DataPreparationService(dbContext);

            var trainingData = dataPreparationService.GetTrainingData();

            IDataView dataView = _mlContext.Data.LoadFromEnumerable(trainingData);

            var pipeline = _mlContext.Transforms.Conversion.MapValueToKey("CustomerId")
                .Append(_mlContext.Transforms.Conversion.MapValueToKey("AccommodationId"))
                .Append(_mlContext.Transforms.Concatenate("Features", "PricePerNight", "ReviewScore"))
                .Append(_mlContext.Recommendation().Trainers.MatrixFactorization(
                    labelColumnName: "Rating",
                    matrixColumnIndexColumnName: "CustomerId",
                    matrixRowIndexColumnName: "AccommodationId",
                    numberOfIterations: 20,
                    approximationRank: 100));

            var model = pipeline.Fit(dataView);
            return model;
        }
    }

    public void SaveModel(ITransformer model, string modelPath)
    {
        try
        {
            Directory.CreateDirectory(Path.GetDirectoryName(modelPath)); // Ensure the directory exists
            _mlContext.Model.Save(model, null, modelPath);
            Console.WriteLine($"Model saved to {modelPath}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Failed to save model: {ex.Message}");
        }
    }
}