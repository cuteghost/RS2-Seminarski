using AutoMapper;
using eBooking.Model.Domain;
using eBooking.Model.Domain.SearchObjects;
using eBooking.Model.DTO;
using eBooking.Services.Database;
using eBooking.Services.Interfaces;

namespace eBooking.Services.Classes;

    public class CityService : BaseCRUDService<City, CityGET, BaseSearchObject, CityPOST, CityPATCH>, ICity
    {
        public CityService(ApplicationDbContext context, IMapper mapper): base(context, mapper) 
        {
            
        }

    public Task<bool> GET()
    {

    }
}



    public override void BeforeInsert(NarudzbaInsertRequest insert, Narudzbe entity)
    {
        entity.KupacId = 1; //todo get from session
        entity.Datum = DateTime.Now;
        entity.BrojNarudzbe = (Context.Narudzbes.Count() + 1).ToString();
        base.BeforeInsert(insert, entity);
    }

    public override Model.Narudzbe Insert(NarudzbaInsertRequest insert)
    {
        var result = base.Insert(insert);
        foreach (var item in insert.Items)
        {
            //call context to store items
            Database.NarudzbaStavke dbItem = new NarudzbaStavke();
            dbItem.NarudzbaId = result.NarudzbaId;
            dbItem.ProizvodId = item.ProizvodId;
            dbItem.Kolicina = item.Kolicina;

            Context.NarudzbaStavkes.Add(dbItem);
        }

        Context.SaveChanges();
        return result;
    }
