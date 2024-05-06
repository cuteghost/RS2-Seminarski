using Models.Models.Domain;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models.Domain;

public class AccommodationImages : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid AccommodationImagesId { get; set; }
    [Required]
    public byte[] Image1 { get; set; }
    [Required]
    public byte[] Image2 { get; set; }
    [Required]
    public byte[] Image3 { get; set; }
    [Required]
    public byte[] Image4 { get; set; }
    [Required]
    public byte[] Image5 { get; set; }

    public byte[]? Image6 { get; set; }
    public byte[]? Image7 { get; set; }
    public byte[]? Image8 { get; set; }
    public byte[]? Image9 { get; set; }
    public byte[]? Image10 { get; set; }
    public byte[]? Image12 { get; set; }
    public byte[]? Image13 { get; set; }
    public byte[]? Image14 { get; set; }
    public byte[]? Image15 { get; set; }
    public byte[]? Image16 { get; set; }
    public byte[]? Image17 { get; set; }
    public byte[]? Image18 { get; set; }
    public byte[]? Image19 { get; set; }
    public byte[]? Image20 { get; set; }


    public bool IsDeleted { get; set; }
}
