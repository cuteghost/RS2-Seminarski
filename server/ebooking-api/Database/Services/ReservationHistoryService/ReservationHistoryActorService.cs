using Microsoft.EntityFrameworkCore;
using Models.DTO.ReservationDTO;

namespace Database.Services.ReservationHistoryService;

public class ReservationHistoryActorService : IReservationHistoryActorService
{
    private const string UnknownActor = "Unknown user";

    private readonly ApplicationDbContext _context;

    public ReservationHistoryActorService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task AttachActors(IReadOnlyCollection<ReservationStatusHistoryGET> history)
    {
        if (history.Count == 0)
            return;

        var userIds = history.Select(h => h.ChangedByUserId).Distinct().ToList();

        // Meko obrisani nalozi se namjerno ne izostavljaju: audit trag mora ostati čitljiv i kad
        // korisnika više nema. Čitaju se samo identifikator i ime, nikad slika.
        var names = await _context.Users
            .AsNoTracking()
            .Where(u => userIds.Contains(u.Id))
            .Select(u => new { u.Id, u.DisplayName })
            .ToDictionaryAsync(u => u.Id, u => u.DisplayName);

        foreach (var row in history)
        {
            row.ChangedByDisplayName = names.TryGetValue(row.ChangedByUserId, out var name) && !string.IsNullOrWhiteSpace(name)
                ? name
                : UnknownActor;
        }
    }
}
