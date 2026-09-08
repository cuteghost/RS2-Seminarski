using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Domain;

namespace Controllers;

[ApiController]
[Route("/")]
public partial class HomeController : Controller
{
    /// <summary>
    /// Provjera da servis odgovara. Jedina ruta koja ne traži prijavu osim prijave i registracije.
    /// </summary>
    [AllowAnonymous]
    [HttpGet]
    public IActionResult RootGet()
    {
        return Ok(new BaseResponse<object>("Service is available.", null));
    }
}
