using Microsoft.AspNetCore.Mvc;

namespace Controllers;

[ApiController]
[Route("/")]
public partial class HomeController : Controller
{
   [HttpGet]
   public  IActionResult RootGet()
   {        
        return  Ok("OK");
   }
}