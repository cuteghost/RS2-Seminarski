using eBooking.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBooking.Services
{
    public class PropertiesService : IPropertiesService
    {
        List<Properties> properties = new List<Properties>
        {
            new Properties()
            {
                PropertyId = 1,
                Name = "Cityscape"
            }
        };

        public IList<Properties> Get()
        {
            return properties;
        }
    }
}
