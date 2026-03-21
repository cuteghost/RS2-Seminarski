namespace PaymentApp.Clients;

public sealed class PaypalApiException : Exception
{
    public PaypalApiException(string operation, int statusCode, string? issue, string? debugId, string rawBody, string message)
        : base(message)
    {
        Operation = operation;
        StatusCode = statusCode;
        Issue = issue;
        DebugId = debugId;
        RawBody = rawBody;
    }

    public string Operation { get; }

    public int StatusCode { get; }

    public string? Issue { get; }

    public string? DebugId { get; }

    public string RawBody { get; }
}
