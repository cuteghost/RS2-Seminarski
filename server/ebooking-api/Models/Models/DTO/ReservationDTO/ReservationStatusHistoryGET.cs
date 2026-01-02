using Models.Domain;

namespace Models.DTO.ReservationDTO;

public class ReservationStatusHistoryGET
{
    public Guid Id { get; set; }
    public Guid ReservationId { get; set; }
    public ReservationStatus? FromStatus { get; set; }
    public ReservationStatus ToStatus { get; set; }
    public Guid ChangedByUserId { get; set; }
    public string ChangedByDisplayName { get; set; } = string.Empty;
    public string ChangedByRole { get; set; } = string.Empty;
    public DateTime ChangedAt { get; set; }
    public string? Reason { get; set; }
}
