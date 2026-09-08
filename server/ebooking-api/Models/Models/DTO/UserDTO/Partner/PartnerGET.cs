namespace Models.DTO.UserDTO.Partner;

public class PartnerGET : UserGET
{
    public Guid Id { get; set; }
    public long TaxId { get; set; }
    public string TaxName { get; set; } = string.Empty;
    public long PhoneNumber { get; set; }
    public Guid CountryId { get; set; }
}
