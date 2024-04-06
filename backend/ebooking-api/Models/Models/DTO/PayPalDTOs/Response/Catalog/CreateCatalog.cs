using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models.DTO.PayPalDTOs.Response.Catalog
{
    public class CreateCatalog
    {
        public string id { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public string type { get; set; }
        public string category { get; set; }
        public string image_url { get; set; }
        public string home_url { get; set; }
        public DateTime create_time { get; set; }
        public DateTime update_time { get; set; }
        //public List<Link> links { get; set; }
    }
}
