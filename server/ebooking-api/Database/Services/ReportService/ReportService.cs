using System.Globalization;
using API.Exceptions;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Models.DTO.ReportDTO;

namespace Database.Services.ReportService;

public class ReportService : IReportService
{
    public const int MaxTop = 25;
    public const int MaxBuckets = 400;

    private readonly ApplicationDbContext _context;

    public ReportService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<ReportOverviewGET> GetOverview(DateTime from, DateTime to, ReportInterval interval, int top)
    {
        var start = from.Date;
        var endExclusive = to.Date.AddDays(1);

        if (endExclusive <= start)
            throw new BusinessException("The end of the period must not be before its start.");

        if (!Enum.IsDefined(interval))
            throw new BusinessException("The interval must be Day, Week or Month.");

        top = Math.Clamp(top, 1, MaxTop);

        var buckets = Buckets(start, endExclusive, interval);
        if (buckets.Count > MaxBuckets)
            throw new BusinessException($"The selected period produces more than {MaxBuckets} intervals. Choose a larger interval.");

        var accommodationsBefore = await _context.Accommodations
            .CountAsync(a => !a.IsDeleted && a.CreatedAt != null && a.CreatedAt < start);
        var usersBefore = await _context.Users
            .CountAsync(u => !u.IsDeleted && u.Joined < start);

        var accommodationDates = await _context.Accommodations
            .AsNoTracking()
            .Where(a => !a.IsDeleted && a.CreatedAt != null && a.CreatedAt >= start && a.CreatedAt < endExclusive)
            .Select(a => a.CreatedAt!.Value)
            .ToListAsync();

        var userDates = await _context.Users
            .AsNoTracking()
            .Where(u => !u.IsDeleted && u.Joined >= start && u.Joined < endExclusive)
            .Select(u => u.Joined)
            .ToListAsync();

        var growth = new List<GrowthPointGET>(buckets.Count);
        var totalAccommodations = accommodationsBefore;
        var totalUsers = usersBefore;

        for (var i = 0; i < buckets.Count; i++)
        {
            var bucketStart = buckets[i];
            var bucketEnd = i + 1 < buckets.Count ? buckets[i + 1] : endExclusive;

            var newAccommodations = accommodationDates.Count(d => d >= bucketStart && d < bucketEnd);
            var newUsers = userDates.Count(d => d >= bucketStart && d < bucketEnd);
            totalAccommodations += newAccommodations;
            totalUsers += newUsers;

            growth.Add(new GrowthPointGET
            {
                PeriodStart = bucketStart,
                Label = Label(bucketStart, interval),
                NewAccommodations = newAccommodations,
                NewUsers = newUsers,
                TotalAccommodations = totalAccommodations,
                TotalUsers = totalUsers
            });
        }

        var paid = _context.Payments
            .AsNoTracking()
            .Where(p => !p.IsDeleted && p.Status == PaymentStatus.Completed
                        && p.CompletedAt != null && p.CompletedAt >= start && p.CompletedAt < endExclusive);

        var totalRevenue = await paid.SumAsync(p => (decimal?)p.Amount) ?? 0m;

        var topCustomers = await paid
            .GroupBy(p => new
            {
                UserId = p.Reservation!.customer.User.Id,
                p.Reservation.customer.User.DisplayName,
                p.Reservation.customer.User.Email
            })
            .Select(g => new TopCustomerGET
            {
                UserId = g.Key.UserId,
                DisplayName = g.Key.DisplayName,
                Email = g.Key.Email,
                PaymentCount = g.Count(),
                TotalPaid = g.Sum(p => p.Amount)
            })
            .OrderByDescending(c => c.TotalPaid)
            .ThenBy(c => c.UserId)
            .Take(top)
            .ToListAsync();

        var topAccommodations = await paid
            .GroupBy(p => new
            {
                p.Reservation!.AccommodationId,
                p.Reservation.accommodation.Name,
                CityName = p.Reservation.accommodation.Location != null && p.Reservation.accommodation.Location.City != null
                    ? p.Reservation.accommodation.Location.City.Name
                    : string.Empty
            })
            .Select(g => new TopAccommodationGET
            {
                AccommodationId = g.Key.AccommodationId,
                Name = g.Key.Name,
                CityName = g.Key.CityName,
                PaymentCount = g.Count(),
                TotalRevenue = g.Sum(p => p.Amount)
            })
            .OrderByDescending(a => a.TotalRevenue)
            .ThenBy(a => a.AccommodationId)
            .Take(top)
            .ToListAsync();

        const string currency = "USD";

        return new ReportOverviewGET
        {
            From = start,
            To = endExclusive.AddDays(-1),
            Interval = interval,
            Currency = currency,
            NewAccommodations = accommodationDates.Count,
            NewUsers = userDates.Count,
            TotalRevenue = totalRevenue,
            Growth = growth,
            TopCustomers = topCustomers,
            TopAccommodations = topAccommodations,
            Charts = new ReportChartsGET
            {
                GrowthSvg = SvgChartBuilder.LineChart(
                    "Accommodations and registered users over time",
                    growth.Select(g => g.Label).ToList(),
                    new List<(string, string, IReadOnlyList<double>)>
                    {
                        ("Total accommodations", "#2563EB", growth.Select(g => (double)g.TotalAccommodations).ToList()),
                        ("Total users", "#F59E0B", growth.Select(g => (double)g.TotalUsers).ToList())
                    }),
                TopCustomersSvg = SvgChartBuilder.HorizontalBarChart(
                    "Customers with the highest payment turnover",
                    topCustomers.Select(c => (c.DisplayName, (double)c.TotalPaid)).ToList(),
                    currency),
                TopAccommodationsSvg = SvgChartBuilder.HorizontalBarChart(
                    "Accommodations with the highest turnover",
                    topAccommodations.Select(a => (a.Name, (double)a.TotalRevenue)).ToList(),
                    currency)
            }
        };
    }

    private static List<DateTime> Buckets(DateTime start, DateTime endExclusive, ReportInterval interval)
    {
        var buckets = new List<DateTime>();
        var cursor = interval switch
        {
            ReportInterval.Month => new DateTime(start.Year, start.Month, 1),
            ReportInterval.Week => start.AddDays(-(((int)start.DayOfWeek + 6) % 7)),
            _ => start
        };

        while (cursor < endExclusive && buckets.Count <= MaxBuckets)
        {
            buckets.Add(cursor < start ? start : cursor);
            cursor = interval switch
            {
                ReportInterval.Month => cursor.AddMonths(1),
                ReportInterval.Week => cursor.AddDays(7),
                _ => cursor.AddDays(1)
            };
        }

        return buckets;
    }

    private static string Label(DateTime periodStart, ReportInterval interval) => interval switch
    {
        ReportInterval.Month => periodStart.ToString("MMM yyyy", CultureInfo.InvariantCulture),
        ReportInterval.Week => $"W{ISOWeek.GetWeekOfYear(periodStart)} {periodStart:yyyy}",
        _ => periodStart.ToString("dd.MM.", CultureInfo.InvariantCulture)
    };
}
