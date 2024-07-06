﻿namespace PaymentApp.Models.PayPal;

public class Capture
{
    public string id { get; set; }
    public string status { get; set; }
    public Amount amount { get; set; }
    public SellerProtection seller_protection { get; set; }
    public bool final_capture { get; set; }
    public string disbursement_mode { get; set; }
    public SellerReceivableBreakdown seller_receivable_breakdown { get; set; }
    public DateTime create_time { get; set; }
    public DateTime update_time { get; set; }
    public List<Link> links { get; set; }
}
