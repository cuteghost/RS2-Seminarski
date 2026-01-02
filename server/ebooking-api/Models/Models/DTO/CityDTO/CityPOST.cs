using System.ComponentModel.DataAnnotations;

namespace Models.DTO.CityDTO;

public class CityPOST
{
    [MaxLength(50)]
    // Donja granica je bila 5 znakova, što odbija stvarne nazive gradova (Pale, Foča, Ilok).
    [MinLength(2)]
    public string Name { get; set; } = string.Empty;

    [Required]
    public Guid CountryId { get; set; }
}
