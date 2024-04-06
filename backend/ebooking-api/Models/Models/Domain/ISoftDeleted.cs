using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Models.Models.Domain;

public interface ISoftDeleted
{
    bool IsDeleted { get; set; }
}
