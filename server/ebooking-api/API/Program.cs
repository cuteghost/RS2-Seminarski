using Models.Domain;
using eBooking.Services.Classes;
using Database;
using Repository.Interfaces;
using Repository.Classes;
using Authentication.Services.HashService;
using TaxiHDbContext;
using Authentication.Services.TokenHandlerService;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using API.Repository.Classes;
using Services.FacebookService;
using Services.Google;
using Services.LocationService;
using Services.RabbitMQService;
using Services;
using Services.Recommendations;

var builder = WebApplication.CreateBuilder(args);

var configuration = builder.Configuration;

// ---------------------------------------------------------------------------
// JWT SIGNING KEY — SECURITY NOTICE
// ---------------------------------------------------------------------------
// The signing key MUST come from the JWT_KEY environment variable.
// A committed RSA key file (tempkey.jwk) was previously checked into git and
// has been neutralized. The key material in that file is COMPROMISED — rotate
// it immediately using the steps below.
//
// HOW TO ROTATE / SET UP FOR THE FIRST TIME:
//   1. Generate a new symmetric key (minimum 32 bytes / 256 bits):
//          openssl rand -base64 64
//   2. Copy the output and set it as an environment variable:
//          - Local dev:  add   JWT_KEY=<value>  to server/.env   (already git-ignored)
//          - Docker:     the docker-compose.yaml already reads JWT_KEY from .env
//          - Production: store the value in your secrets manager / CI secrets
//   3. Also set JWT_ISSUER and JWT_AUDIENCE (e.g. "localhost" for local dev).
//   4. Revoke the old key: treat all JWTs signed before this rotation as
//      untrusted. Force all users to log in again if needed.
//   5. NEVER hardcode a key value here or in appsettings.json.
// ---------------------------------------------------------------------------
var jwtKey = Environment.GetEnvironmentVariable("JWT_KEY") ?? configuration["JWT:key"];
var jwtIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? configuration["JWT:issuer"];
var jwtAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? configuration["JWT:audience"];
var facebookAppId = Environment.GetEnvironmentVariable("FacebookAppId") ?? configuration["FacebookAppId"];
var facebookAppSecret = Environment.GetEnvironmentVariable("FacebookAppSecret") ?? configuration["FacebookAppSecret"];

// Fail fast: the app cannot start securely without a signing key.
if (string.IsNullOrWhiteSpace(jwtKey))
    throw new InvalidOperationException(
        "JWT signing key is not configured. Set the JWT_KEY environment variable. " +
        "See the rotation instructions in API/Program.cs for details.");

configuration["JWT:key"] = jwtKey;
configuration["JWT:issuer"] = jwtIssuer;
configuration["JWT:audience"] = jwtAudience;


// Add services to the container.

#region Database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    var dbConnectionString = !string.IsNullOrWhiteSpace(ServiceRegistry.ReadFromEnv()) ? ServiceRegistry.ReadFromEnv() : ServiceRegistry.ExtractConnectionString();
    Console.WriteLine(dbConnectionString);
    ServiceRegistry.ConfigureDbContext(options, dbConnectionString);
});
#endregion

/*--------------------------------------------------------------------------------------*/
builder.Services.AddScoped<IHashService, HashService>();
/*--------------------------------------------------------------------------------------*/
builder.Services.AddScoped<ITokenHandlerService, TokenHandlerService>();
/*--------------------------------------------------------------------------------------*/
builder.Services.AddSingleton<ILocationService, LocationService>();
/*--------------------------------------------------------------------------------------*/

builder.Services.AddScoped<ILoginRepository, LoginRepository>();
builder.Services.AddTransient<IGenericRepository<City>, GenericRepository<City>>();
builder.Services.AddTransient<IGenericRepository<Country>, GenericRepository<Country>>();
builder.Services.AddTransient<IGenericRepository<Location>, GenericRepository<Location>>();
builder.Services.AddTransient<IGenericRepository<User>, GenericRepository<User>>();
builder.Services.AddTransient<IGenericRepository<Customer>, GenericRepository<Customer>>();
builder.Services.AddTransient<ICustomerRepository, CustomerRepository>();
builder.Services.AddTransient<IGenericRepository<Partner>, GenericRepository<Partner>>();
builder.Services.AddTransient<IGenericRepository<Administrator>, GenericRepository<Administrator>>();
builder.Services.AddTransient<IGenericRepository<Accommodation>, GenericRepository<Accommodation>>();
builder.Services.AddTransient<IGenericRepository<Review>, GenericRepository<Review>>();
builder.Services.AddTransient<IGenericRepository<Reservation>, GenericRepository<Reservation>>();
builder.Services.AddTransient<IUserRepository, UserRepository>();
builder.Services.AddTransient<IAdministratorRepository, AdministratorRepository>();
builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.AddSingleton<IFacebookAuthService, FacebookAuthService>();
builder.Services.AddScoped<IMessageProducer, MessageProducer>();

#region Recommendation
builder.Services.AddSingleton<AccommodationRecommendationService>();
builder.Services.AddScoped<RecommendationService>(provider =>
{
    return new RecommendationService("MLModels/MLmodel.zip");
});


#endregion
#region AuthConfiguration

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
    });

#endregion

builder.Services.AddScoped<IGoogleAuthService, GoogleAuthService>();
builder.Services.Configure<GoogleAuthConfig>(builder.Configuration.GetSection("Google"));

builder.Services.Configure<FacebookAuthConfig>(configuration.GetSection("Facebook"));
builder.Services.AddHttpClient("Facebook", c =>
{
    c.BaseAddress = new Uri("https://graph.facebook.com/v11.0/");
    c.DefaultRequestHeaders.Add("Accept", "application/json");
});

builder.Services.AddAutoMapper(typeof(Program).Assembly);

//CORS solution
builder.Services.AddCors(option =>
{
    option.AddPolicy("FirstPolicy", builder =>
    {
        builder.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();

    });
});

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

var recommendationService = app.Services.GetRequiredService<AccommodationRecommendationService>();
var model = recommendationService.TrainModel();
var modelPath = Path.Combine(Directory.GetCurrentDirectory(), "MLModels", "MLmodel.zip");
recommendationService.SaveModel(model, modelPath);

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("FirstPolicy");

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();