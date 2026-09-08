using Models.Domain;
using eBooking.Services.Classes;
using Database;
using Repository.Interfaces;
using Repository.Classes;
using Authentication.Services.HashService;
using Seminarski.Database;
using Authentication.Services.TokenHandlerService;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using API.Repository.Classes;
using Services.FacebookService;
using Services.Google;
using Services.LocationService;
using Services.RabbitMQService;
using API.Exceptions;
using Authentication.Extensions;
using Services.ReviewService;
using Database.Services.ProfanityFilterService;
using Services.ReservationService;
using Services.RecommendationService;
using Services.CountryService;
using Services.CityService;
using Services.LocationCatalogService;
using Services.CurrentUserService;
using Database.Data.Seed;
using Database.Services.AccommodationCatalogService;
using Database.Services.AccommodationImageService;
using Database.Services.AccommodationWriteService;
using Database.Services.AccountService;
using Database.Services.ReservationGuestService;
using Database.Services.ReservationHistoryService;
using Database.Services.UserImageService;
using Database.Services.ProfileService;
using Database.Services.PaymentService;

var builder = WebApplication.CreateBuilder(args);

var configuration = builder.Configuration;

// The signing key must come from the JWT_KEY environment variable, never hardcoded here or in
// appsettings.json: a previously committed key file (tempkey.jwk) leaked and is treated as
// permanently compromised, so all tokens signed with it must be rejected.
//
// To rotate: generate 32+ bytes (e.g. `openssl rand -base64 64`), set it as JWT_KEY (local
// .env, docker-compose secrets, or the production secrets manager) along with JWT_ISSUER and
// JWT_AUDIENCE, then treat every JWT signed before the rotation as untrusted.
var jwtKey = Environment.GetEnvironmentVariable("JWT_KEY") ?? configuration["JWT:key"];
var jwtIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? configuration["JWT:issuer"];
var jwtAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? configuration["JWT:audience"];
var facebookAppId = Environment.GetEnvironmentVariable("FacebookAppId") ?? configuration["FacebookAppId"];
var facebookAppSecret = Environment.GetEnvironmentVariable("FacebookAppSecret") ?? configuration["FacebookAppSecret"];

if (string.IsNullOrWhiteSpace(jwtKey))
    throw new InvalidOperationException(
        "JWT signing key is not configured. Set the JWT_KEY environment variable. " +
        "See the rotation instructions in API/Program.cs for details.");

configuration["JWT:key"] = jwtKey;
configuration["JWT:issuer"] = jwtIssuer;
configuration["JWT:audience"] = jwtAudience;

if (!string.IsNullOrWhiteSpace(facebookAppId))
    configuration["Facebook:AppId"] = facebookAppId;

if (!string.IsNullOrWhiteSpace(facebookAppSecret))
    configuration["Facebook:AppSecret"] = facebookAppSecret;


#region Database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    var dbConnectionString = !string.IsNullOrWhiteSpace(ServiceRegistry.ReadFromEnv()) ? ServiceRegistry.ReadFromEnv() : ServiceRegistry.ExtractConnectionString();
    ServiceRegistry.ConfigureDbContext(options, dbConnectionString);
});
#endregion

builder.Services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));

#region SpecificServices
builder.Services.AddScoped<IHashService, HashService>();
builder.Services.AddScoped<ITokenHandlerService, TokenHandlerService>();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddSingleton<ILocationService, LocationService>();
builder.Services.AddScoped<ICountryService, CountryService>();
builder.Services.AddScoped<ICityService, CityService>();
builder.Services.AddScoped<ILocationCatalogService, LocationCatalogService>();
builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.Configure<ProfanityFilterOptions>(builder.Configuration.GetSection("Profanity"));
builder.Services.AddScoped<IProfanityFilterService, ProfanityFilterService>();
builder.Services.AddScoped<IReservationService, ReservationService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<IReservationGuestService, ReservationGuestService>();
builder.Services.AddScoped<IReservationHistoryActorService, ReservationHistoryActorService>();
builder.Services.AddScoped<IUserImageService, UserImageService>();
builder.Services.AddScoped<IAccountService, AccountService>();
builder.Services.AddScoped<IProfileService, ProfileService>();
builder.Services.AddScoped<IAccommodationImageService, AccommodationImageService>();
builder.Services.AddScoped<IAccommodationCatalogService, AccommodationCatalogService>();
builder.Services.AddScoped<IAccommodationWriteService, AccommodationWriteService>();
// MessageProducer holds a long-lived RabbitMQ connection (EasyNetQ IBus), so it must be a
// singleton - a scoped/transient lifetime would open a new broker connection per request.
builder.Services.AddSingleton<IMessageProducer, MessageProducer>();
#endregion

#region SpecificRepositories
builder.Services.AddScoped<ILoginRepository, LoginRepository>();
builder.Services.AddScoped<ICustomerRepository, CustomerRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IAdministratorRepository, AdministratorRepository>();
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();
#endregion

#region OAuthParties
builder.Services.AddSingleton<IFacebookAuthService, FacebookAuthService>();
builder.Services.AddScoped<IGoogleAuthService, GoogleAuthService>();
builder.Services.Configure<GoogleAuthConfig>(builder.Configuration.GetSection("Google"));

builder.Services.Configure<FacebookAuthConfig>(configuration.GetSection("Facebook"));
builder.Services.AddHttpClient("Facebook", c =>
{
    c.BaseAddress = new Uri("https://graph.facebook.com/v11.0/");
    c.DefaultRequestHeaders.Add("Accept", "application/json");
});
#endregion

#region Recommendation
builder.Services.AddSingleton<AccommodationRecommendationService>();
builder.Services.AddScoped<RecommendationService>(provider =>
{
    return new RecommendationService(
        "MLModels/MLmodel.zip",
        provider.GetRequiredService<ILogger<RecommendationService>>());
});
// Trains the ML model in the background so startup and the health check are never blocked on it.
builder.Services.AddHostedService<RecommendationModelHostedService>();
#endregion

#region AuthConfiguration

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };

        options.Events = new JwtBearerEvents().WithTokenVersionCheck().RejectPaymentTickets();
    });

#endregion


builder.Services.AddAutoMapper(typeof(Program).Assembly);

var corsOrigins = (Environment.GetEnvironmentVariable("CORS_ORIGINS") ?? "http://localhost:9999,http://localhost9090,http://localhost:8888")
    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

builder.Services.AddCors(option =>
{
    option.AddPolicy("FirstPolicy", policy =>
    {
        policy.WithOrigins(corsOrigins).AllowAnyMethod().AllowAnyHeader().AllowCredentials();
    });
});

builder.Services.AddControllers();

// [ApiController] provjerava ModelState prije nego se akcija uopšte pozove, pa ta grana
// nikad ne prođe kroz GlobalExceptionHandler. Podrazumijevani odgovor je ProblemDetails
// ({ type, title, status, errors, traceId }), dakle drugi oblik od { statusCode, message,
// details } koji vraća sve ostalo, pa se ovdje ručno svodi na isti oblik.
builder.Services.Configure<ApiBehaviorOptions>(options =>
{
    options.InvalidModelStateResponseFactory = context =>
    {
        var invalidKeys = context.ModelState
            .Where(entry => entry.Value != null && entry.Value.Errors.Count > 0)
            .Select(entry => entry.Key)
            .ToList();

        // Kad čitanje JSON-a padne, ASP.NET prijavi i naziv parametra akcije ("reservationDto")
        // i putanju do polja ("$.startDate"). Klijent ne zna kako se parametar zove na serveru,
        // pa se u tom slučaju nabrajaju samo putanje.
        if (invalidKeys.Any(key => key.StartsWith("$.", StringComparison.Ordinal)))
            invalidKeys = invalidKeys.Where(key => key.StartsWith("$.", StringComparison.Ordinal)).ToList();

        var invalidFields = invalidKeys
            .Select(NormalizeFieldName)
            .Where(name => !string.IsNullOrEmpty(name))
            .Distinct(StringComparer.Ordinal)
            .ToList();

        // Kad tijelo nije ispravan JSON, ModelState nosi samo ključ "$" bez naziva polja,
        // pa nabrajanje polja nema šta prikazati.
        var message = invalidFields.Count > 0
            ? $"The request is invalid. Please check these fields: {string.Join(", ", invalidFields)}."
            : "The request body is invalid and could not be read.";

        return new BadRequestObjectResult(new ErrorResponse
        {
            StatusCode = StatusCodes.Status400BadRequest,
            Message = message,
            Details = null
        });
    };
});

// ModelState ključ je ili naziv svojstva modela ("Name"), ili JSON putanja ("$.pricePerNight"),
// ili "$" za neuspjelo čitanje cijelog tijela. Klijent šalje camelCase, pa se naziv vraća u
// obliku u kojem ga je i poslao.
static string NormalizeFieldName(string key)
{
    if (string.IsNullOrEmpty(key) || key == "$")
        return string.Empty;

    var name = key.StartsWith("$.", StringComparison.Ordinal) ? key[2..] : key;
    if (name.Length == 0)
        return string.Empty;

    return char.ToLowerInvariant(name[0]) + name[1..];
}

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

await DatabaseInitializer.InitializeAsync(app.Services);

app.UseExceptionHandler();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("FirstPolicy");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();