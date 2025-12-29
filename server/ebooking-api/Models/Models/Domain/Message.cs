using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Message
{
    [Key]
    [Required]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }
    [Required]
    public Guid SenderId { get; set; }
    [Required]
    public string Content { get; set; } = String.Empty;
    [Required]
    public DateTime Timestamp { get; set; }
    [Required]
    public bool IsRead { get; set; } = false;
    [Required]
    public Guid ChatId { get; set; }

    [ForeignKey("SenderId")]
    public virtual User? Sender { get; set; }
    [ForeignKey("ChatId")]
    public virtual Chat? Chat { get; set; }


}