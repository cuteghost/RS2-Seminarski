using Database;
using Database.Services.MessagingService;
using EasyNetQ;
using EBooking.Worker;
using EBooking.Worker.Handlers;
using Models.Messaging;
using Seminarski.Database;

var builder = Host.CreateApplicationBuilder(args);

var rabbitMqConnectionString = RabbitMqConnection.FromEnvironment();
var dbConnectionString = ServiceRegistry.ReadFromEnv();
var smtpOptions = SmtpOptions.FromEnvironment();

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    ServiceRegistry.ConfigureDbContext(options, dbConnectionString));

builder.Services.AddSingleton<IBus>(_ => RabbitHutch.CreateBus(rabbitMqConnectionString));
builder.Services.AddScoped<IMessageRepository, MessageRepository>();
builder.Services.AddScoped<ChatMessageHandler>();
builder.Services.AddScoped<NotificationHandler>();
builder.Services.AddSingleton(smtpOptions);
builder.Services.AddScoped<PasswordResetEmailHandler>();
builder.Services.AddHostedService<RabbitMqConsumer>();

var host = builder.Build();
host.Run();
