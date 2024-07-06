using System.ComponentModel.DataAnnotations;


namespace Models.DTO.AccommodationsDTO.SearchDTO;

public class SearchDTO
{
    double PriceFrom { get; set; }
    double PriceTo { get; set; }
    [Required]
    String City { get; set; }
    [Required]
    Date DateFrom { get; set; }
    [Required]
    Date DateTo { get; set; }
    [Required]
    int NumberOfGuests { get; set; }
}
