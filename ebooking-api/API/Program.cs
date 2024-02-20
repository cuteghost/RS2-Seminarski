using Models.Domain;
using eBooking.Services.Classes;
using Database;
using eBooking.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Repository.Interfaces;
using Repository.Classes;
using Services.HashService;
using TaxiHDbContext;

var builder = WebApplication.CreateBuilder(args);

var configuration = builder.Configuration;

// Load JWT settings from environment variables or appsettings.json
var jwtKey = Environment.GetEnvironmentVariable("JWT_KEY") ?? configuration["JWT:key"];
var jwtIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? configuration["JWT:issuer"];
var jwtAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? configuration["JWT:audience"];

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
builder.Services.AddScoped<IHashService, HashService>();

builder.Services.AddTransient<IGenericRepository<City>, GenericRepository<City>>();
builder.Services.AddTransient<IGenericRepository<Country>, GenericRepository<Country>>();
builder.Services.AddTransient<IGenericRepository<Location>, GenericRepository<Location>>();
builder.Services.AddTransient<IGenericRepository<User>, GenericRepository<User>>();
builder.Services.AddTransient<IGenericRepository<Customer>, GenericRepository<Customer>>();
builder.Services.AddTransient<ICustomerRepository, CustomerRepository>();
builder.Services.AddTransient<IGenericRepository<Partner>, GenericRepository<Partner>>();
builder.Services.AddTransient<IGenericRepository<Administrator>, GenericRepository<Administrator>>();


builder.Services.AddAutoMapper(typeof(Program).Assembly);


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

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();