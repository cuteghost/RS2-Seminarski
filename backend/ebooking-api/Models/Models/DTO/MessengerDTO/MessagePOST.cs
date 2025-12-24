using System;
using System.ComponentModel.DataAnnotations;

namespace Models.DTO.MessengerDTO;

public class MessagePOST
{
    [Required]
    public Guid SenderId { get; set; }
    [Required]
    public Guid ChatId { get; set; }
    [Required]
    public string Content { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.Now;
}
