using Models.Domain;

namespace Services.CurrentUserService;

/// <summary>
/// Identitet korisnika koji je poslao trenutni zahtjev, pročitan iz JWT tokena.
///
/// <para>
/// Kontroleri više ne primaju <c>[FromHeader] string Authorization</c> niti bilo koji
/// <c>userId</c> iz rute ili body-ja — sve što se tiče „ko je ovo poslao" dolazi odavde.
/// Time nestaje mogućnost da klijent pošalje tuđi identifikator i dobije tuđe podatke.
/// </para>
/// </summary>
public interface ICurrentUserService
{
    /// <summary>Da li zahtjev nosi ispravan token.</summary>
    bool IsAuthenticated { get; }

    /// <summary>
    /// <c>Users.Id</c> prijavljenog korisnika. Baca ako zahtjev nije autentifikovan —
    /// endpoint bez <c>[Authorize]</c> je greška u kodu, ne greška klijenta.
    /// </summary>
    Guid UserId { get; }

    /// <summary>Email prijavljenog korisnika. Baca pod istim uslovima kao <see cref="UserId"/>.</summary>
    string Email { get; }

    /// <summary>
    /// Uloga iz tokena: jedna od vrijednosti u <see cref="Models.Constants.Roles"/>,
    /// ili prazan string ako je token bez uloge.
    /// </summary>
    string Role { get; }

    /// <summary><c>Customers.Id</c> prijavljenog korisnika, ili <c>Guid.Empty</c> ako nije kupac.</summary>
    Task<Guid> GetCustomerIdAsync();

    /// <summary><c>Partners.Id</c> prijavljenog korisnika, ili <c>Guid.Empty</c> ako nije partner.</summary>
    Task<Guid> GetPartnerIdAsync();

    /// <summary><c>Administrators.Id</c> prijavljenog korisnika, ili <c>Guid.Empty</c> ako nije administrator.</summary>
    Task<Guid> GetAdministratorIdAsync();
}
