using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models.DTO.MessengerDTO;

public class ChatGET
{
    public Guid Id { get; set; }
    public Guid User1Id { get; set; }
    public Guid User2Id { get; set; }
    public String User1 { get; set; }
    public String User2 { get; set; }
    public List<MessageGET> Messages { get; set; }
}
