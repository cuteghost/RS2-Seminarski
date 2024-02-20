using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

internal class ReviewImage
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public long ReviewImagesId { get; set; }
    [ForeignKey("Review")]
    public Review ReviewId { get; set; }
    [Required]
    public byte[] Image { get; set; }

    public virtual Review Review { get; set; }
}
