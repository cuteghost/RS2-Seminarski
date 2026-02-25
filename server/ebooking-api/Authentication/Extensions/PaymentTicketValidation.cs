using System.Security.Claims;
using Authentication.Services.TokenHandlerService;
using Microsoft.AspNetCore.Authentication.JwtBearer;

namespace Authentication.Extensions;

public static class PaymentTicketValidation
{
    public static JwtBearerEvents RejectPaymentTickets(this JwtBearerEvents events)
    {
        var previous = events.OnTokenValidated;

        events.OnTokenValidated = async context =>
        {
            if (previous != null)
                await previous(context);

            var purpose = context.Principal?.FindFirstValue(TokenHandlerService.PurposeClaim);
            if (!string.IsNullOrEmpty(purpose))
                context.Fail("A payment ticket is not valid outside the payment service.");
        };

        return events;
    }

    public static JwtBearerEvents RequirePaymentTicket(this JwtBearerEvents events)
    {
        var previous = events.OnTokenValidated;

        events.OnTokenValidated = async context =>
        {
            if (previous != null)
                await previous(context);

            var purpose = context.Principal?.FindFirstValue(TokenHandlerService.PurposeClaim);
            if (!string.Equals(purpose, TokenHandlerService.PaymentPurpose, StringComparison.Ordinal))
                context.Fail("Payment requires a ticket issued for that reservation.");
        };

        return events;
    }
}
