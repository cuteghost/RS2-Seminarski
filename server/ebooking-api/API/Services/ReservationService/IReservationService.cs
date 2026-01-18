using System.Linq.Expressions;
using Models.Domain;

namespace Services.ReservationService;

/// <summary>
/// Jedino mjesto na kojem se odlučuje da li je termin slobodan i da li je promjena stanja
/// rezervacije dozvoljena.
///
/// <para>
/// Prije je provjera preklapanja bila napisana dva puta — u <c>ReservationController</c> i u
/// <c>SearchController</c> — i obje kopije su imale istu grešku: hvatale su samo rezervacije
/// <b>potpuno sadržane</b> u novom rasponu, pa je djelimično preklapanje prolazilo i isti
/// smještaj se mogao rezervisati dva puta.
/// </para>
/// </summary>
public interface IReservationService
{
    /// <summary>Prelazi dozvoljeni iz zadatog stanja. Prazno za završna stanja.</summary>
    IReadOnlyCollection<ReservationStatus> AllowedTransitions(ReservationStatus from);

    /// <summary>
    /// Uslov „ova rezervacija zauzima termin [<paramref name="start"/>, <paramref name="end"/>)
    /// na zadatom smještaju". Otkazane i odbijene rezervacije ne zauzimaju termin.
    /// </summary>
    Expression<Func<Reservation, bool>> Overlapping(Guid accommodationId, DateTime start, DateTime end);

    /// <summary>
    /// Isti uslov, ali sa strane smještaja — <c>NOT EXISTS</c> podupit, pa pretraga može
    /// filtrirati i straničiti u jednom upitu umjesto da učita sve pa odbaci u memoriji.
    /// </summary>
    Expression<Func<Accommodation, bool>> AvailableBetween(DateTime start, DateTime end);

    /// <summary>
    /// Baca <c>BusinessException</c> ako je termin zauzet.
    /// </summary>
    Task EnsureTermIsFree(Guid accommodationId, DateTime start, DateTime end);

    /// <summary>
    /// Kreira rezervaciju u stanju <see cref="ReservationStatus.Pending"/> i upisuje prvi red
    /// audit traga.
    /// </summary>
    Task<Reservation> Create(Reservation reservation, Accommodation accommodation);

    /// <summary>
    /// Mijenja stanje rezervacije: provjerava da li prelaz postoji, da li ga pozivalac smije
    /// izvesti, upisuje audit trag i šalje obavještenje kroz red poruka.
    /// </summary>
    Task<Reservation> ChangeStatus(Guid reservationId, ReservationStatus target, string? reason);

    /// <summary>Audit trag jedne rezervacije, najnovije na vrhu.</summary>
    Task<IReadOnlyList<ReservationStatusHistory>> GetHistory(Guid reservationId);
}
