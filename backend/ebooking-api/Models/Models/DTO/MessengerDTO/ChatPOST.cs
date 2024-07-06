
using System.ComponentModel.DataAnnotations;

namespace Models.DTO.MessengerDTO;

public class ChatPOST
{
    [Required]
    public Guid User2Id { get; set; }
}
