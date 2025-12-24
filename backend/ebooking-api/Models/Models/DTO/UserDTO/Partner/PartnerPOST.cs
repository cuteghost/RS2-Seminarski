namespace Models.DTO.UserDTO.Partner;

public class PartnerPOST
{
    public Guid UserId { get; set; }
    public Guid CountryId { get; set; }
    public long TaxId { get; set; }
    public string TaxName { get; set; } = string.Empty;
    public long PhoneNumber { get; set; }
}

