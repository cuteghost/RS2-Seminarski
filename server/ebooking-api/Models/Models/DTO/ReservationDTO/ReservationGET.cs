using Models.Domain;
using Models.DTO.AccommodationDTO;
using System.ComponentModel.DataAnnotations;

namespace Models.DTO.ReservationDTO;

public class ReservationGET
{
    [Required]
    public Guid Id { get; set; }
    [Required]
    public Guid AccommodationId { get; set; }
    [Required]
    public int NumberOfGuests { get; set; }
    [Required]
    public DateTime StartDate { get; set; }
    [Required]
    public DateTime EndDate { get; set; }
    [Required]
    public bool IsRated { get; set; }

    [Required]
    public decimal PricePerNight { get; set; }

    [Required]
    public decimal TotalPrice { get; set; }

    /// <summary>1 na čekanju · 2 potvrđeno · 3 otkazano · 4 odbijeno · 5 završeno.</summary>
    [Required]
    public ReservationStatus Status { get; set; }

    public DateTime? StatusChangedAt { get; set; }

    /// <summary>Razlog posljednje promjene stanja; popunjen kod odbijanja i najčešće kod otkazivanja.</summary>
    public string? StatusReason { get; set; }

    [Required]
    public bool IsPaid { get; set; }
    // AccommodationGET se koristi umjesto domenskog entiteta da odgovor ne nosi interna polja
    // poput IsDeleted i cijelu City/Country granu.
    [Required]
    public AccommodationGET accommodation { get; set; }
    public string? ThumbnailUrl { get; set; }

    public ReservationGuestGET? Guest { get; set; }
}
