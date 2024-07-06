using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models.DTO.ReviewDTO;

public class ReviewPOST
{
    public int Rating { get; set; }
    public bool Satisfaction { get; set; }
    public bool WouldRecommend { get; set; }
    public string Comment { get; set; }
    public Guid AccommodationId { get; set; }

}
