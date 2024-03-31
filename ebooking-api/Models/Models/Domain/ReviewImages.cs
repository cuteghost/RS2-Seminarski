using Models.Models.Domain;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

internal class ReviewImage : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }
    [ForeignKey("Review")]
    public Review ReviewId { get; set; }
    [Required]
    public byte[] Image { get; set; }

    public virtual Review Review { get; set; }

    public bool IsDeleted { get; set; }

}
