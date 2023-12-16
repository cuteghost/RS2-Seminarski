﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eBooking.Model.Domain;

public class AccommodationDetails
{
    [ForeignKey("AccommodationId")]
    public Guid AccommodationId { get; set; }
    public Accommodations Accommodations { get; set; }
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid AccommodationDetailId { get; set; }
    public bool Bathub { get; set; }
    public bool Balcony { get; set; }
    public bool PrivateBathroom { get; set; }
    public bool AC { get; set; }
    public bool Terrace { get; set; }
    public bool Kitchen { get; set; }
    public bool PrivatePool { get; set; }
    public bool CoffeeMachine { get; set; }
    public bool View { get; set; }
    public bool SeaView { get; set; }
    public bool WashingMachine { get; set; }
    public bool SpaTub { get; set; }
    public bool SoundProof { get; set; }
    public bool Breakfast { get; set; }
}
