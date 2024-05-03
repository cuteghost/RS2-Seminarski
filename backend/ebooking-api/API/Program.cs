using Models.Domain;
using eBooking.Services.Classes;
using Database;
using Repository.Interfaces;
using Repository.Classes;
using Services.HashService;
using TaxiHDbContext;
using Services.TokenHandlerService;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using API.Repository.Classes;
using Services.FacebookService;
using Services.Google;

var builder = WebApplication.CreateBuilder(args);

var configuration = builder.Configuration;

// Load JWT settings from environment variables or appsettings.json
var jwtKey = Environment.GetEnvironmentVariable("JWT_KEY") ?? configuration["JWT:key"];
var jwtIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? configuration["JWT:issuer"];
var jwtAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? configuration["JWT:audience"];
var facebookAppId = Environment.GetEnvironmentVariable("FacebookAppId") ?? configuration["FacebookAppId"];
var facebookAppSecret = Environment.GetEnvironmentVariable("FacebookAppSecret") ?? configuration["FacebookAppSecret"];

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
builder.Services.AddTransient<IUserRepository, UserRepository>();
builder.Services.AddTransient<IAdministratorRepository, AdministratorRepository>();
builder.Services.AddSingleton<IFacebookAuthService, FacebookAuthService>();

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