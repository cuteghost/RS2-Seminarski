using System.Net;
using Microsoft.AspNetCore.Authentication.JwtBearer;

namespace PaymentApp.Extensions;

public static class AuthenticationFeedback
{
    public static JwtBearerEvents WithReadableChallenge(this JwtBearerEvents events)
    {
        events.OnChallenge = async context =>
        {
            context.HandleResponse();

            await Write(context.HttpContext, StatusCodes.Status401Unauthorized,
                "The payment ticket is invalid or has expired. Return to the app and start the payment again.");
        };

        events.OnForbidden = context => Write(context.HttpContext, StatusCodes.Status403Forbidden,
            "This account is not authorized for this payment.");

        return events;
    }

    private static async Task Write(HttpContext context, int statusCode, string message)
    {
        if (context.Response.HasStarted)
            return;

        context.Response.StatusCode = statusCode;

        if (!HttpMethods.IsGet(context.Request.Method))
        {
            await context.Response.WriteAsJsonAsync(new { message });
            return;
        }

        context.Response.ContentType = "text/html; charset=utf-8";

        await context.Response.WriteAsync(
            "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\">"
            + "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
            + "<title>Payment</title></head>"
            + "<body style=\"font-family:sans-serif;padding:24px;text-align:center\"><p>"
            + WebUtility.HtmlEncode(message)
            + "</p></body></html>");
    }
}
