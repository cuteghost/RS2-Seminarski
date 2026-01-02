using System.ComponentModel.DataAnnotations;
using Models.Domain;

namespace Models.DTO.ReservationDTO;

/// <summary>
/// Jedan zahtjev za promjenu stanja rezervacije. Namjerno jedan endpoint umjesto zasebnih ruta
/// za prihvatanje, odbijanje, otkazivanje i zaključivanje — pravila su tada na jednom mjestu,
/// a ne razasuta po kontroleru.
/// </summary>
public class ReservationStatusPATCH
{
    [Required]
    public Guid ReservationId { get; set; }

    [Required]
    public ReservationStatus Status { get; set; }

    /// <summary>Obavezan pri odbijanju, dobrodošao pri otkazivanju.</summary>
    [MaxLength(500)]
    public string? Reason { get; set; }
}
