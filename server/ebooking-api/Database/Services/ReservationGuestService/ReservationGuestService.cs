using Microsoft.EntityFrameworkCore;
using Models.DTO.ReservationDTO;
using Models.DTO.UserDTO;

namespace Database.Services.ReservationGuestService;

public class ReservationGuestService : IReservationGuestService
{
    private readonly ApplicationDbContext _context;

    public ReservationGuestService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task AttachGuests(IReadOnlyCollection<ReservationGET> reservations)
    {
        if (reservations.Count == 0)
            return;

        var reservationIds = reservations.Select(r => r.Id).Distinct().ToList();

        var rows = await _context.Reservations
            .AsNoTracking()
            .Where(r => reservationIds.Contains(r.Id))
            .Select(r => new
            {
                ReservationId = r.Id,
                UserId = r.customer.User.Id,
                r.customer.User.DisplayName,
                r.customer.User.FirstName,
                r.customer.User.LastName,
                r.customer.User.Email,
                HasImage = r.customer.User.Image != null && r.customer.User.Image.Length > 0
            })
            .ToListAsync();

        var guests = rows.ToDictionary(row => row.ReservationId, row => new ReservationGuestGET
        {
            UserId = row.UserId,
            DisplayName = row.DisplayName,
            FirstName = row.FirstName,
            LastName = row.LastName,
            Email = row.Email,
            ImageUrl = row.HasImage ? UserImageUrl.For(row.UserId) : null
        });

        foreach (var reservation in reservations)
            reservation.Guest = guests.TryGetValue(reservation.Id, out var guest) ? guest : null;
    }
}
