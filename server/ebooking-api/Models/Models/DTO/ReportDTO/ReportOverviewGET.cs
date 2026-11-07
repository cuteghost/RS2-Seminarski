namespace Models.DTO.ReportDTO;

public enum ReportInterval
{
    Day = 1,
    Week = 2,
    Month = 3
}

public class GrowthPointGET
{
    public DateTime PeriodStart { get; set; }
    public string Label { get; set; } = string.Empty;
    public int NewAccommodations { get; set; }
    public int NewUsers { get; set; }
    public int TotalAccommodations { get; set; }
    public int TotalUsers { get; set; }
}

public class TopCustomerGET
{
    public Guid UserId { get; set; }
    public string DisplayName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public int PaymentCount { get; set; }
    public decimal TotalPaid { get; set; }
}

public class TopAccommodationGET
{
    public Guid AccommodationId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string CityName { get; set; } = string.Empty;
    public int PaymentCount { get; set; }
    public decimal TotalRevenue { get; set; }
}

public class ReportChartsGET
{
    public string GrowthSvg { get; set; } = string.Empty;
    public string TopCustomersSvg { get; set; } = string.Empty;
    public string TopAccommodationsSvg { get; set; } = string.Empty;
}

public class ReportOverviewGET
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
    public ReportInterval Interval { get; set; }
    public string Currency { get; set; } = "USD";
    public int NewAccommodations { get; set; }
    public int NewUsers { get; set; }
    public decimal TotalRevenue { get; set; }
    public List<GrowthPointGET> Growth { get; set; } = new();
    public List<TopCustomerGET> TopCustomers { get; set; } = new();
    public List<TopAccommodationGET> TopAccommodations { get; set; } = new();
    public ReportChartsGET Charts { get; set; } = new();
}
