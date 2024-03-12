using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models.DTO.FacebookDTO;

public class Data
{
    [JsonProperty("is_valid")]
    public bool IsValid { get; set; }

    [JsonProperty("user_id")]
    public string UserId { get; set; }
}
