using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Chat
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [Required]
    public Guid User1Id { get; set; }

    [Required]
    public Guid User2Id { get; set; }

    [ForeignKey("User1Id")]
    public virtual User? User1 { get; set; }

    [ForeignKey("User2Id")]
    public virtual User? User2 { get; set; }

    public virtual ICollection<Message> Messages { get; set; } = new List<Message>();
}
