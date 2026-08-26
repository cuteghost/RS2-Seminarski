using PaymentApp.Clients;


var builder = WebApplication.CreateBuilder(args);
var paypalClientId = Environment.GetEnvironmentVariable("PAYPAL_CLIENT_ID");
var paypalSecretKey= Environment.GetEnvironmentVariable("PAYPAL_SECRET_KEY");
var paypalEnv = Environment.GetEnvironmentVariable("PAYPAL_ENV");
if (paypalClientId == null || paypalEnv == null || paypalSecretKey == null || paypalClientId == "" || paypalEnv == "" || paypalSecretKey == "")
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.Error.WriteLine($"CRITICAL ERROR: One of required environment variable for paypal is not set.");
    Console.ResetColor();
    Environment.Exit(1);
}
// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddSingleton(x =>
    new PaypalClient(paypalClientId, paypalSecretKey, paypalEnv)
);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}


//app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
