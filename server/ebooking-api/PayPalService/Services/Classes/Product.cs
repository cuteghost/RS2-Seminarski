using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Models.DTO.PayPalDTOs.Request.Catalog;
using Services.Interfaces;

namespace Services.Classes
{
    internal class Product : IProduct
    {
        public bool AddProduct(CreateProduct product)
        {
            return false;
        }

        public bool DeleteProduct(string id)
        {
            throw new NotImplementedException();
        }

        public bool ListAllProducts()
        {
            throw new NotImplementedException();
        }

        public bool ListProductDetails(string id)
        {
            throw new NotImplementedException();
        }

        public bool UpdateProduct()
        {
            throw new NotImplementedException();
        }
    }
}
