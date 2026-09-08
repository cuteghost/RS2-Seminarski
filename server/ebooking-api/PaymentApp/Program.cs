using System.Text;
using Database;
using Authentication.Extensions;
using Authentication.Services.TokenHandlerService;
using Database.Services.PaymentService;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using PaymentApp.Clients;
using PaymentApp.Extensions;
using Seminarski.Database;

var builder = WebApplication.CreateBuilder(args);

var paypalClientId = Environment.GetEnvironmentVariable("PAYPAL_CLIENT_ID");
var paypalSecretKey = Environment.GetEnvironmentVariable("PAYPAL_SECRET_KEY");
var paypalEnv = Environment.GetEnvironmentVariable("PAYPAL_ENV");
if (string.IsNullOrWhiteSpace(paypalClientId) || string.IsNullOrWhiteSpace(paypalEnv) || string.IsNullOrWhiteSpace(paypalSecretKey))
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.Error.WriteLine("CRITICAL ERROR: One of required environment variable for paypal is not set.");
    Console.ResetColor();
    Environment.Exit(1);
}

var jwtKey = Environment.GetEnvironmentVariable("JWT_KEY");
if (string.IsNullOrWhiteSpace(jwtKey))
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.Error.WriteLine("CRITICAL ERROR: JWT_KEY is not set. See the rotation instructions in API/Program.cs.");
    Console.ResetColor();
    Environment.Exit(1);
}

builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    var dbConnectionString = ServiceRegistry.ReadFromEnv();
    ServiceRegistry.ConfigureDbContext(options, dbConnectionString);
});

builder.Services.AddScoped<IPaymentService, Database.Services.PaymentService.PaymentService>();
builder.Services.AddScoped<ITokenHandlerService, TokenHandlerService>();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = false,
            ValidateAudience = false,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };

        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                if (string.IsNullOrEmpty(context.Token))
                {
                    var fromQuery = context.Request.Query["token"].ToString();
                    if (!string.IsNullOrEmpty(fromQuery))
                        context.Token = fromQuery;
                }

                return Task.CompletedTask;
            }
        }.WithTokenVersionCheck().RequirePaymentTicket().WithReadableChallenge();
    });

builder.Services.AddAuthorization();
builder.Services.AddControllersWithViews();
builder.Services.AddHttpClient<PaypalClient, PaypalClient>((httpClient, provider) =>
    new PaypalClient(paypalClientId, paypalSecretKey, paypalEnv, httpClient,
        provider.GetRequiredService<ILogger<PaypalClient>>()));

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
