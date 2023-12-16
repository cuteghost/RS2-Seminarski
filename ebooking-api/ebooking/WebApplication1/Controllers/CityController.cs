using eProdaja.Controllers;
using eBooking.Model.Domain;
using eBooking.Model.DTO;
using eBooking.Services.Interfaces;
using eBooking.Model.Domain.SearchObjects;

namespace eBooking.Controllers;

public class CityController : BaseCRUDController<City, BaseSearchObject, CityPOST, CityPATCH>
{
    public CityController(ICity service) : base(service)
    {

    }
}


﻿using eProdaja.Model.Requests;
using eProdaja.Model.SearchObjects;
using eProdaja.Services;

namespace eProdaja.Controllers
{
    public class NarudzbeController : BaseCRUDController<Model.Narudzbe, BaseSearchObject, NarudzbaInsertRequest, NarudzbaUpdateRequest>
    {
        public NarudzbeController(INarudzbeService service)
            : base(service)
        {
        }
    }
}