using Microsoft.AspNetCore.Mvc;

namespace PaymentService.Controllers;

public class Product : Controller
{
    public Product()
    {
        
    }
    public async Task<IActionResult> CreateProduct()
    {
        return Content("Ok");
    }
}
