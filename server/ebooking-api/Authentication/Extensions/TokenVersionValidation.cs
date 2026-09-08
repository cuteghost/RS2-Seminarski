using System.Security.Claims;
using Authentication.Services.TokenHandlerService;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.DependencyInjection;

namespace Authentication.Extensions;

public static class TokenVersionValidation
{
    public static JwtBearerEvents WithTokenVersionCheck(this JwtBearerEvents events)
    {
        var previous = events.OnTokenValidated;

        events.OnTokenValidated = async context =>
        {
            if (previous != null)
                await previous(context);

            var principal = context.Principal;
            if (principal == null)
            {
                context.Fail("The token could not be read.");
                return;
            }

            var rawUserId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
            var rawVersion = principal.FindFirstValue(TokenHandlerService.TokenVersionClaim);

            if (!Guid.TryParse(rawUserId, out var userId) || !int.TryParse(rawVersion, out var version))
            {
                context.Fail("The token was issued before server-side logout was introduced. Please log in again.");
                return;
            }

            var tokenHandler = context.HttpContext.RequestServices.GetRequiredService<ITokenHandlerService>();
            if (!await tokenHandler.IsTokenVersionValid(userId, version))
                context.Fail("The token was revoked by logout or the account no longer exists.");
        };

        return events;
    }
}
