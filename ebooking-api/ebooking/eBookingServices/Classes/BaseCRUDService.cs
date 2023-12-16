using AutoMapper;
using eBooking.Model.Domain.SearchObjects;
using eBooking.Model.DTO;
using eBooking.Services.Database;
using eBooking.Services.Interfaces;

namespace eBooking.Services.Classes;

public class BaseCRUDService<T, TDb, TSearch, TInsert, TUpdate>
    : BaseService<T, TDb, TSearch>, ICRUDService<T, TSearch, TInsert, TUpdate>
        where T : class where TDb : class where TSearch : BaseSearchObject where TInsert : class where TUpdate : class
{
    public BaseCRUDService(ApplicationDbContext context, IMapper mapper)
    : base(context, mapper) { }

    public virtual T Insert(TInsert insert)
    {
        var set = Context.Set<TDb>();

        TDb entity = Mapper.Map<TDb>(insert);

        set.Add(entity);

        BeforeInsert(insert, entity);

        Context.SaveChanges();

        return Mapper.Map<T>(entity);
    }

    public virtual void BeforeInsert(TInsert insert, TDb entity)
    {

    }

    public virtual T Update(int id, TUpdate update)
    {
        var set = Context.Set<TDb>();

        var entity = set.Find(id);

        if (entity != null)
        {
            Mapper.Map(update, entity);
        }
        else
        {
            return null;
        }

        Context.SaveChanges();

        return Mapper.Map<T>(entity);

    }
}