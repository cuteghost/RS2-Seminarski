using Models.DTO.ReportDTO;

namespace Database.Services.ReportService;

public interface IReportService
{
    Task<ReportOverviewGET> GetOverview(DateTime from, DateTime to, ReportInterval interval, int top);
}
