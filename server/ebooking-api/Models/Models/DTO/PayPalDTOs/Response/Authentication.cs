using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models.Models.DTO.PayPalDTOs.Response;

public class Authentication
{
    public string scope { get; set; } = string.Empty;
    public string access_token { get; set; } = string.Empty;
    public string token_type { get; set; } = string.Empty;
    public string app_id { get; set; } = string.Empty;
    public int expires_in { get; set; }
    public string nonce { get; set; } = string.Empty;
}
