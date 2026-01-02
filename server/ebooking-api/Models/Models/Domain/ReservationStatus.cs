namespace Models.Domain;

/// <summary>
/// Stanje rezervacije. Vrijednosti su eksplicitne jer se serijalizuju kao broj i zapisuju u
/// bazu — mijenjanje redoslijeda bi promijenilo značenje postojećih redova.
/// </summary>
public enum ReservationStatus
{
    /// <summary>Kreirana, čeka odgovor vlasnika smještaja.</summary>
    Pending = 1,

    /// <summary>Vlasnik je prihvatio. Termin je zauzet.</summary>
    Confirmed = 2,

    /// <summary>Otkazao gost ili administrator. Termin je oslobođen.</summary>
    Cancelled = 3,

    /// <summary>Vlasnik je odbio, uz obavezan razlog. Termin je oslobođen.</summary>
    Rejected = 4,

    /// <summary>Boravak je završen.</summary>
    Completed = 5
}
