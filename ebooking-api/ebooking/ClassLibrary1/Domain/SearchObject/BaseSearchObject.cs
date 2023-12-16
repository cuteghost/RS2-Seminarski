using System;
using System.Collections.Generic;
using System.Text;

namespace eBooking.Model.Domain.SearchObjects;

public class BaseSearchObject
{
    public int? Page { get; set; }
    public int? PageSize { get; set; }
}