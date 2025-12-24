using EasyNetQ;
using Microsoft.Extensions.Configuration;
using Models.Domain;
using System;
using System.Text.Json;

namespace Services.RabbitMQService;

public class MessageProducer : IMessageProducer
{
    private readonly IBus _bus;
    private readonly string _host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
    private readonly string _port = Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672";
    private readonly string _username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "user";
    private readonly string _password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "mypass";
    private readonly string _virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

    public MessageProducer()
    {
        var connectionString = $"host={_host};virtualHost={_virtualhost};username={_username};password={_password};port={_port}";
        _bus = RabbitHutch.CreateBus(connectionString);
    }

    public void SendMessage(WelcomeMessage message)
    {
        var rabbitMqMessageParsed = System.Text.Json.JsonSerializer.Serialize(message);
        _bus.PubSub.Publish(message);
        Console.WriteLine(" [x] Sent {0}", rabbitMqMessageParsed);
    }
}


//using EasyNetQ;
//using Microsoft.AspNetCore.SignalR;
//using Microsoft.Extensions.Configuration;
//using Models.Domain;
//using RabbitMQ.Client;
//using RabbitMQ.Client.Events;
//using System.Text;
//using System.Text.Json;

//using System.Threading.Channels;

//namespace Services.RabbitMQService;

//public class MessageProducer : IMessageProducer
//{

//    private readonly string _host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
//    private readonly string _port = Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672";
//    private readonly string _username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "user";
//    private readonly string _password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "mypass";
//    private readonly string _virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

//    private readonly IModel _channel;

//    public MessageProducer()
//    { 
//        var factory = new ConnectionFactory() { HostName = _host , UserName = _username , Password = _password, VirtualHost = _virtualhost , Port = int.Parse(_port)};
//        var connection = factory.CreateConnection();
//        _channel = connection.CreateModel();
//        _channel.QueueDeclare(queue: "Reservation_added",
//                             durable: false,
//                             exclusive: false,
//                             autoDelete: false,
//                             arguments: null);
//    }

//    public void SendMessage(WelcomeMessage message)
//    {
//        var properties = _channel.CreateBasicProperties();
//        properties.Persistent = true;

//        // Set metadata
//        properties.ContentType = "text/plain";
//        properties.ContentEncoding = "UTF-8";
//        properties.MessageId = Guid.NewGuid().ToString();
//        properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());
//        properties.Type = "Reservation_added";
//        properties.Headers = new Dictionary<string, object>
//    {
//        { "origin", "Reservation_added" },
//    };
//        var rabbitMqMessageParsed = JsonSerializer.Serialize(message);
//        var body = Encoding.UTF8.GetBytes(rabbitMqMessageParsed);

//        _channel.BasicPublish(exchange: "",
//                                routingKey: "Reservation_added",
//                                basicProperties: properties,
//                                body: body);

//        Console.WriteLine(" [x] Sent {0}", rabbitMqMessageParsed);
//    }

//public void SendingMessage(string message)
//{
//    try
//    {
//        var factory = new ConnectionFactory
//        {
//            HostName = _host,
//            UserName = _username,
//            Password = _password,
//            VirtualHost = _virtualhost,
//        };

//        using var connection = factory.CreateConnection();
//        using var channel = connection.CreateModel();

//        channel.QueueDeclare(queue: "reservation_notifications",
//                             durable: true,
//                             exclusive: true
//                          );


//        var body = Encoding.UTF8.GetBytes(message);

//        channel.BasicPublish(exchange: string.Empty,
//                             routingKey: "reservation_added",
//                             basicProperties: null,
//                             body: body);
//    }
//    catch (Exception ex)
//    {
//        Console.WriteLine($"An error occurred while sending message to RabbitMQ: {ex.Message}");

//    }
//}
//public void SendingObject<T>(T obj)
//{
//    var host = _host;
//    var username = _username;
//    var password = _password;
//    var virtualhost = _virtualhost;

//    using var bus = RabbitHutch.CreateBus($"host={host};virtualHost={virtualhost};username={username};password={password}");

//    bus.PubSub.Publish(obj);
//}


//}
