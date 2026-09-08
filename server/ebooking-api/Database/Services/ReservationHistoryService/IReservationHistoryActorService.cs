using Models.DTO.ReservationDTO;

namespace Database.Services.ReservationHistoryService;

public interface IReservationHistoryActorService
{
    /// <summary>
    /// Upisuje čitljivo ime onoga ko je promijenio stanje u svaki red audit traga. Jedan upit
    /// za cijelu listu, bez obzira na broj redova.
    /// </summary>
    Task AttachActors(IReadOnlyCollection<ReservationStatusHistoryGET> history);
}
