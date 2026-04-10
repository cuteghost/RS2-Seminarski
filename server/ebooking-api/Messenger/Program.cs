using Authentication.Extensions;
using Authentication.Services.HashService;
using Authentication.Services.TokenHandlerService;
using Database;
using Messenger.Repositories;
using Messenger.Repository;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.SignalR;
using System.Text;
using Seminarski.Database;
using Messenger;
using Messenger.Middleware;
using EasyNetQ;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
var configuration = builder.Configuration;

// The signing key must come from the JWT_KEY environment variable (same key shared with the
// API service, and subject to the same rotation notice in API/Program.cs).
var jwtKey = Environment.GetEnvironmentVariable("JWT_KEY") ?? configuration["JWT:key"];
var jwtIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? configuration["JWT:issuer"];
var jwtAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? configuration["JWT:audience"];

if (string.IsNullOrWhiteSpace(jwtKey))
    throw new InvalidOperationException(
        "JWT signing key is not configured. Set the JWT_KEY environment variable.");

configuration["JWT:key"] = jwtKey;
configuration["JWT:issuer"] = jwtIssuer;
configuration["JWT:audience"] = jwtAudience;

#region Database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    var dbConnectionString = !string.IsNullOrWhiteSpace(ServiceRegistry.ReadFromEnv()) ? ServiceRegistry.ReadFromEnv() : ServiceRegistry.ExtractConnectionString();
    ServiceRegistry.ConfigureDbContext(options, dbConnectionString);
});
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

builder.Services.AddCors(option =>
{
    option.AddPolicy("FirstPolicy", builder =>
    {
        builder.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
});

builder.Services.AddAutoMapper(typeof(Program).Assembly);

builder.Services.AddScoped<IHashService, HashService>();
builder.Services.AddScoped<ITokenHandlerService, TokenHandlerService>();
builder.Services.AddScoped<IMessageRepository, MessageRepository>();
builder.Services.AddSingleton<IChatHub, ChatHub>();
builder.Services.AddScoped<INotifierService, NotifierService>();
builder.Services.AddSignalR();
builder.Services.AddHostedService<ConsumeRabbitMQHostedService>();


var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseMiddleware<WebSocketsMiddleware>();
app.UseCors("FirstPolicy");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.MapHub<ChatHub>("/chathub");

app.Run();
