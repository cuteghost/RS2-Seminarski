using System.ComponentModel.DataAnnotations;

namespace Models.DTO.ReservationDTO;

public class ReservationPATCH
{
    [Required]
    public int NumberOfGuests { get; set; }
    [Required]
    public DateTime StartDate { get; set; }
    [Required]
    public DateTime EndDate { get; set; }
    [Required]
    public Guid AccommodationId { get; set; }
}
