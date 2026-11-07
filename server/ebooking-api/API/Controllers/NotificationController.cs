using Database.Services.NotificationService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.Constants;
using Models.Domain;
using Models.DTO.NotificationDTO;
using Services.CurrentUserService;

namespace Controllers;

[ApiController]
[Authorize]
[Route("/api/[controller]")]
public class NotificationController : Controller
{
    private readonly INotificationService _notifications;
    private readonly ICurrentUserService _currentUser;

    public NotificationController(INotificationService notifications, ICurrentUserService currentUser)
    {
        _notifications = notifications;
        _currentUser = currentUser;
    }

    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] bool unreadOnly = false,
                                         [FromQuery] int page = 1,
                                         [FromQuery] int pageSize = Pagination.DefaultPageSize)
    {
        (page, pageSize) = Pagination.Normalize(page, pageSize);

        var (items, totalCount) = await _notifications.GetForUser(_currentUser.UserId, unreadOnly, page, pageSize);

        return Ok(new PagedResponse<NotificationGET>("Notifications retrieved successfully.", items, page, pageSize, totalCount));
    }

    [HttpGet]
    [Route("UnreadCount")]
    public async Task<IActionResult> UnreadCount()
    {
        var count = await _notifications.CountUnread(_currentUser.UserId);

        return Ok(new BaseResponse<int>("Unread notification count retrieved successfully.", count));
    }

    [HttpPatch]
    [Route("Read/{id}")]
    public async Task<IActionResult> MarkRead([FromRoute] Guid id)
    {
        var notification = await _notifications.MarkRead(_currentUser.UserId, id);

        return Ok(new BaseResponse<NotificationGET>("Notification marked as read.", notification));
    }

    [HttpPatch]
    [Route("ReadAll")]
    public async Task<IActionResult> MarkAllRead()
    {
        var changed = await _notifications.MarkAllRead(_currentUser.UserId);

        return Ok(new BaseResponse<int>("All notifications marked as read.", changed));
    }
}
