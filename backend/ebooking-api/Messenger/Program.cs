using Authentication.Services.HashService;
using Authentication.Services.TokenHandlerService;
using Database;
using Messenger.Repositories;
using Messenger.Repository;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.SignalR;
using System.Text;
using TaxiHDbContext;
using Messenger;
using Messenger.Middleware;
using EasyNetQ;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
var configuration = builder.Configuration;

var jwtKey = Environment.GetEnvironmentVariable("JWT_KEY") ?? configuration["JWT:key"];
var jwtIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? configuration["JWT:issuer"];
var jwtAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? configuration["JWT:audience"];
configuration["JWT:key"] = jwtKey;
configuration["JWT:issuer"] = jwtIssuer;
configuration["JWT:audience"] = jwtAudience;

#region Database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    var dbConnectionString = !string.IsNullOrWhiteSpace(ServiceRegistry.ReadFromEnv()) ? ServiceRegistry.ReadFromEnv() : ServiceRegistry.ExtractConnectionString();
    Console.WriteLine(dbConnectionString);
    ServiceRegistry.ConfigureDbContext(options, dbConnectionString);
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

builder.Services.AddCors(option =>
{
    option.AddPolicy("FirstPolicy", builder =>
    {
        builder.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
});

builder.Services.AddAutoMapper(typeof(Program).Assembly);

/*--------------------------------------------------------------------------------------*/
builder.Services.AddScoped<IHashService, HashService>();
/*--------------------------------------------------------------------------------------*/
builder.Services.AddScoped<ITokenHandlerService, TokenHandlerService>();
/*--------------------------------------------------------------------------------------*/
builder.Services.AddScoped<IMessageRepository, MessageRepository>();
/*--------------------------------------------------------------------------------------*/
builder.Services.AddSingleton<IChatHub, ChatHub>();
/*--------------------------------------------------------------------------------------*/
builder.Services.AddScoped<INotifierService, NotifierService>();
/*--------------------------------------------------------------------------------------*/
builder.Services.AddSignalR();
/*--------------------------------------------------------------------------------------*/
builder.Services.AddHostedService<ConsumeRabbitMQHostedService>();


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();
app.UseMiddleware<WebSocketsMiddleware>();
app.UseCors("FirstPolicy");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Map SignalR hub
app.MapHub<ChatHub>("/chathub");

app.Run();
