using Models.Domain;
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
    public Accommodation accommodation { get; set; }
    [Required]
    public byte[] Thumbnail { get; set; }
}
