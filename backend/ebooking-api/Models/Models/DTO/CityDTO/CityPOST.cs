﻿using System.ComponentModel.DataAnnotations;

namespace Models.DTO.CityDTO;
public class CityPOST
{
    [MaxLength(50)]
    [MinLength(5)]
    public string Name { get; set; } = string.Empty;
    public Guid CountryId { get; set; }
}
