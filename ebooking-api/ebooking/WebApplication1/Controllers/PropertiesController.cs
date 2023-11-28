using eBooking.Model;
using eBooking.Services;
using Microsoft.AspNetCore.Mvc;

namespace eBooking.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public  class PropertiesController : ControllerBase
    {
        private readonly IPropertiesService _propertiesService;
        public PropertiesController(IPropertiesService propertiesService )
        {
            _propertiesService = propertiesService;
        }
        [HttpGet]
        public IEnumerable<Properties> Get()
        {
            return _propertiesService.Get();
        }
    }
}
