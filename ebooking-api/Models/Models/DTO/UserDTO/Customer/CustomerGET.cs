using Models.Domain;

namespace Models.DTO.UserDTO.Customer;

public class CustomerGET : UserGET
{    
    public Guid Id { get; set; }
}
