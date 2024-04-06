using Models.Models.Domain;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models.Domain;

internal class AccommodationImages : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid AccommodationImagesId { get; set; }
    [ForeignKey("AccommodationDetailsId")]
    public AccommodationDetails AccommodationDetails { get; set; }
    [Required]
    public byte[] Image { get; set; }
    public bool IsDeleted { get; set; }
}
