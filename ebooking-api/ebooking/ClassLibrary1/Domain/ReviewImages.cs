using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBooking.Model.Domain;

internal class ReviewImage
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid ReviewImagesId { get; set; }
    [ForeignKey("ReviewId")]
    public Review Review { get; set; }
    [Required]
    public byte[] Image { get; set; }
}
