using Database;
using eBooking.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.DTO.CountryDTO;
using Models.Models.Domain;
using System.Linq.Expressions;

namespace eBooking.Services.Classes;

public class GenericRepository<T> : IGenericRepository<T> where T : class, ISoftDeleted
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
                entityToDelete.IsDeleted = true;
                await _ctx.SaveChangesAsync();
                return true;
            }
            return false;
        }
        catch (Exception)
        {

            return false;
        }
    }

    public async Task<IEnumerable<T>> GetAll(bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties)
    {
        IQueryable<T> query = _entity.Where(e => !e.IsDeleted || includeDeleted); ;
        foreach (var includeProperty in includeProperties)
            query = query.Include(includeProperty);
        return await query.ToListAsync();
    }

    public async Task<T> GetById(Expression<Func<T, bool>> predicate, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties)
    {
        IQueryable<T> query = _entity.Where(e => !e.IsDeleted || includeDeleted);
        foreach (var i in includeProperties)
        {
            query = query.Include(i);

        }
        var entityToReturn = await query.AsNoTracking().SingleOrDefaultAsync(predicate);

        if (entityToReturn != null)
        {
            return entityToReturn;
        }
        return null;
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
