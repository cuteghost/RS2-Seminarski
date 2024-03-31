using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models.DTO.PayPalDTOs.Request.Catalog
{
    public class CreateProduct
    {
        public string name { get; set; } = string.Empty;
        public string type { get; set; } = string.Empty;
        public string description { get; set; } = string.Empty;
        public string category { get; set; } = string.Empty;
        public string image_url { get; set; } = string.Empty;
        public string home_url { get; set; } = string.Empty;
    }
}
