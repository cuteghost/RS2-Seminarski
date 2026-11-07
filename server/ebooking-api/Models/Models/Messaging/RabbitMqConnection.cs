namespace Models.Messaging;

public static class RabbitMqConnection
{
    public static string FromEnvironment()
    {
        var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST");
        var port = Environment.GetEnvironmentVariable("RABBITMQ_PORT");
        var username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME");
        var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD");
        var virtualHost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST");

        var missing = new List<string>();
        if (string.IsNullOrWhiteSpace(host)) missing.Add("RABBITMQ_HOST");
        if (string.IsNullOrWhiteSpace(username)) missing.Add("RABBITMQ_USERNAME");
        if (string.IsNullOrWhiteSpace(password)) missing.Add("RABBITMQ_PASSWORD");

        if (missing.Count > 0)
            throw new InvalidOperationException(
                $"RabbitMQ is not configured. Set the following environment variables: {string.Join(", ", missing)}.");

        if (string.IsNullOrWhiteSpace(port))
            port = "5672";

        if (string.IsNullOrWhiteSpace(virtualHost))
            virtualHost = "/";

        return $"host={host};virtualHost={virtualHost};username={username};password={password};port={port}";
    }
}
