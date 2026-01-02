using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

/// <summary>
/// Audit trag promjena stanja rezervacije: ko, kada, iz čega u šta i zašto.
///
/// <para>
/// Red se nikad ne mijenja niti briše — svaka promjena stanja dodaje novi. Prvi red rezervacije
/// ima <see cref="FromStatus"/> <c>null</c>, jer prije kreiranja nije bilo prethodnog stanja.
/// </para>
/// </summary>
public class ReservationStatusHistory : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [ForeignKey("Reservation")]
    public Guid ReservationId { get; set; }

    public ReservationStatus? FromStatus { get; set; }

    [Required]
    public ReservationStatus ToStatus { get; set; }

    /// <summary><c>Users.Id</c> onoga ko je promjenu napravio.</summary>
    [Required]
    public Guid ChangedByUserId { get; set; }

    /// <summary>Uloga iz tokena u trenutku promjene, da se kasnije vidi u kom svojstvu je postupio.</summary>
    [Required]
    [MaxLength(20)]
    public string ChangedByRole { get; set; } = string.Empty;

    [Required]
    public DateTime ChangedAt { get; set; }

    [MaxLength(500)]
    public string? Reason { get; set; }

    public bool IsDeleted { get; set; } = false;

    public virtual Reservation? Reservation { get; set; }
}
