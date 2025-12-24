using Models.DTO.PayPalDTOs.Request.Catalog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services.Interfaces;

public interface IProduct
{
    public bool AddProduct(CreateProduct product);
    public bool UpdateProduct();
    public bool DeleteProduct(string id);
    public bool ListAllProducts();
    public bool ListProductDetails(string id);

}
