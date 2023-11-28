using eBooking.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBooking.Services
{
    public interface IPropertiesService
    {
        IList<Properties> Get();
    }
}
