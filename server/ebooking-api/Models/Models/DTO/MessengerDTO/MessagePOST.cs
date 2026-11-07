using System.ComponentModel.DataAnnotations;

namespace Models.DTO.MessengerDTO;

public class MessagePOST
{
    [Required]
    public Guid ChatId { get; set; }

    [Required]
    public string Content { get; set; } = string.Empty;
}
