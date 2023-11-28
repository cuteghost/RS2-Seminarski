using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBooking.Model
{
    public partial class Properties
    {
        public int PropertyId { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public double PricePerNight { get; set; }
        public int NumberOfBedrooms { get; set; }
        public byte[] Image { get; set; }
        public byte[] ImageThumb { get; set; }
        public bool? Status { get; set; }
        public string StateMachine { get; set; }
    }
}
