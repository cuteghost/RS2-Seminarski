using Database;
using eBooking.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.DTO.CountryDTO;
using System.Linq.Expressions;

namespace eBooking.Services.Classes;

public class GenericRepository<T> : IGenericRepository<T> where T : class
{
    private readonly ApplicationDbContext _ctx;
    private readonly DbSet<T> _entity;
    public GenericRepository(ApplicationDbContext ctx)
    {
        _ctx = ctx;
        _entity = _ctx.Set<T>();
    }

    public async Task<bool> Add(T model)
    {
        try
        {
            await _entity.AddAsync(model);
            await _ctx.SaveChangesAsync();
            return true;
        }
        catch (Exception)
        {
            return false;
        }
    }

    public async Task<bool> Delete(Expression<Func<T, bool>> predicate)
    {
        try
        {
            var entityToDelete = await _entity.SingleOrDefaultAsync(predicate);
            if (entityToDelete != null)
            {
                _entity.Remove(entityToDelete);
                _ctx.SaveChanges();
                return true;
            }
            return false;
        }
        catch (Exception)
        {

            return false;
        }
    }

    public async Task<IEnumerable<T>> GetAll(params Expression<Func<T, object>>[] includeProperties)
    {
        IQueryable<T> query = _entity;
        foreach (var includeProperty in includeProperties)
            query = query.Include(includeProperty);
        return await query.ToListAsync();
    }

    public async Task<T> GetById(int id)
    {
        return await _entity.FindAsync(id);
    }

    public async Task<bool> Update(Expression<Func<T, bool>> predicate, T model)
    {
        try
        {
            var entityToUpdate = await _entity.AsNoTracking().SingleOrDefaultAsync(predicate);
            if (entityToUpdate != null)
            {
                _entity.Update(model);
                _ctx.SaveChanges();
                return true;
            }
            return false;
        }
        catch (Exception)
        {

            return false;
        }
    }
}
