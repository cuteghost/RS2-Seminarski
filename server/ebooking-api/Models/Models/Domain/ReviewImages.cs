using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class ReviewImage : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [Required]
    public Guid ReviewId { get; set; }

    [Required]
    public byte[] Image { get; set; } = Array.Empty<byte>();

    public virtual Review? Review { get; set; }

    public bool IsDeleted { get; set; }
}
