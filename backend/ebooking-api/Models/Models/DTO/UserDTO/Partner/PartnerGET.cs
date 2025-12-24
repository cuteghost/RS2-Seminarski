namespace Models.DTO.UserDTO.Partner;

public class PartnerGET
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public long TaxId { get; set; }
    public string TaxName { get; set; }
    public long PhoneNumber { get; set; }
    public Guid CountryId { get; set; }
}
