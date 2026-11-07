using Database.Services.ReportService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.Domain;
using Models.DTO.ReportDTO;

namespace Controllers;

[ApiController]
[Authorize(Roles = Roles.Administrator)]
[Route("/api/[controller]")]
public class ReportController : Controller
{
    private const int DefaultTop = 10;

    private readonly IReportService _reports;

    public ReportController(IReportService reports)
    {
        _reports = reports;
    }

    [HttpGet]
    [Route("Overview")]
    public async Task<IActionResult> Overview([FromQuery] DateTime? from = null,
                                              [FromQuery] DateTime? to = null,
                                              [FromQuery] ReportInterval interval = ReportInterval.Month,
                                              [FromQuery] int top = DefaultTop)
    {
        var end = (to ?? DateTime.UtcNow).Date;
        var start = (from ?? end.AddMonths(-11)).Date;

        var overview = await _reports.GetOverview(start, end, interval, top);

        return Ok(new BaseResponse<ReportOverviewGET>("Report generated successfully.", overview));
    }
}
