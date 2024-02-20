using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models.DTO.PayPalDTOs.Request.Catalog
{
    public class CreateProduct
    {
        public string name { get; set; }
        public string type { get; set; }
        public string description { get; set; }
        public string category { get; set; }
        public string image_url { get; set; }
        public string home_url { get; set; }
    }
}
