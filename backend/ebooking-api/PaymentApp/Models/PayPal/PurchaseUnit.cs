using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PaymentApp.Models.PayPal;

public sealed class PurchaseUnit
{
    public Amount amount { get; set; }
    public string reference_id { get; set; }
    public Payments payments { get; set; }
}
