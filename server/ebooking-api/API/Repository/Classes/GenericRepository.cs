using Database;
using Repository.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
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
            await _entity.AddAsync(model);
            await _ctx.SaveChangesAsync();
            return true;
    }

    public async Task<bool> Delete(Expression<Func<T, bool>> predicate)
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

    public async Task<IEnumerable<T>> GetAll(Expression<Func<T, bool>> predicate, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties)
    {
        IQueryable<T> query = _entity;

        if (!includeDeleted)
        {
            query = query.Where(e => !e.IsDeleted);
        }

        query = query.Where(predicate);
        foreach (var includeProperty in includeProperties)
            query = query.Include(includeProperty);
        return await query.ToListAsync();
    }

    public async Task<IEnumerable<T>> GetAll(bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties)
    {
        IQueryable<T> query = _entity;

        if (!includeDeleted)
        {
            query = query.Where(e => !e.IsDeleted);
        }
        foreach (var includeProperty in includeProperties)
            query = query.Include(includeProperty);
        return await query.ToListAsync();
    }

    public async Task<T> Get(Expression<Func<T, bool>> predicate, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties)
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

    public async Task<bool> Update(Expression<Func<T, bool>> predicate, T model, params Expression<Func<T, object>>[] includeProperties)
    {
        
        IQueryable<T> query = _entity;
        foreach (var includeProperty in includeProperties)
        {
            query = query.Include(includeProperty);
        }
        var entityToUpdate = await query.SingleOrDefaultAsync(predicate);

        if (entityToUpdate != null)
        {
                
            _ctx.Entry(entityToUpdate).CurrentValues.SetValues(model);

                
            _ctx.Entry(entityToUpdate).State = EntityState.Modified;

            await _ctx.SaveChangesAsync();
            return true;
        }
        return false;
        
    }
    public async Task<int> Count(Expression<Func<T, bool>> predicate, bool includeDeleted = false)
    {
        IQueryable<T> query = _entity;

        if (!includeDeleted)
        {
            query = query.Where(e => !e.IsDeleted);
        }

        return await query.CountAsync(predicate);
    }

    public async Task<bool> Any(Expression<Func<T, bool>> predicate, bool includeDeleted = false)
    {
        IQueryable<T> query = _entity;

        if (!includeDeleted)
        {
            query = query.Where(e => !e.IsDeleted);
        }

        return await query.AnyAsync(predicate);
    }

    public async Task<List<TResult>> Project<TResult>(Expression<Func<T, TResult>> selector, bool includeDeleted = false)
    {
        IQueryable<T> query = _entity;

        if (!includeDeleted)
        {
            query = query.Where(e => !e.IsDeleted);
        }

        return await query.AsNoTracking().Select(selector).ToListAsync();
    }

    public async Task<List<TResult>> Project<TResult>(Expression<Func<T, bool>> predicate, Expression<Func<T, TResult>> selector, bool includeDeleted = false)
    {
        IQueryable<T> query = _entity;

        if (!includeDeleted)
        {
            query = query.Where(e => !e.IsDeleted);
        }

        return await query.Where(predicate).AsNoTracking().Select(selector).ToListAsync();
    }

    /// <summary>
    /// Stabilan poredak za straničenje. Bez <c>OrderBy</c> EF uz <c>OFFSET/FETCH</c> generiše
    /// <c>ORDER BY (SELECT 1)</c>, pa SQL Server ne garantuje isti raspored redova između dva
    /// upita - isti red se može pojaviti na dvije stranice ili biti preskočen. Svi entiteti u
    /// modelu imaju <c>uniqueidentifier</c> primarni ključ pa se sortira po njemu.
    /// </summary>
    private IQueryable<T> OrderForPaging(IQueryable<T> query)
    {
        var key = _ctx.Model.FindEntityType(typeof(T))?.FindPrimaryKey();
        if (key == null || key.Properties.Count != 1 || key.Properties[0].ClrType != typeof(Guid))
            return query;

        return query.OrderBy(e => EF.Property<Guid>(e, key.Properties[0].Name));
    }

    public async Task<(IEnumerable<T> Items, int TotalCount)> GetPaged(int page, int pageSize, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties)
    {
        IQueryable<T> query = _entity;

        if (!includeDeleted)
        {
            query = query.Where(e => !e.IsDeleted);
        }
        foreach (var includeProperty in includeProperties)
            query = query.Include(includeProperty);

        var totalCount = await query.CountAsync();

        var items = await OrderForPaging(query)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (items, totalCount);
    }

    public async Task<(IEnumerable<T> Items, int TotalCount)> GetPaged(Expression<Func<T, bool>> predicate, int page, int pageSize, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties)
    {
        IQueryable<T> query = _entity;

        if (!includeDeleted)
        {
            query = query.Where(e => !e.IsDeleted);
        }

        query = query.Where(predicate);

        foreach (var includeProperty in includeProperties)
            query = query.Include(includeProperty);

        var totalCount = await query.CountAsync();

        var items = await OrderForPaging(query)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (items, totalCount);
    }

    public async Task<(IEnumerable<T> Items, int TotalCount)> GetPaged<TKey>(Expression<Func<T, bool>> predicate, Expression<Func<T, TKey>> orderBy, bool descending, int page, int pageSize, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties)
    {
        IQueryable<T> query = _entity;

        if (!includeDeleted)
        {
            query = query.Where(e => !e.IsDeleted);
        }

        query = query.Where(predicate);

        foreach (var includeProperty in includeProperties)
            query = query.Include(includeProperty);

        var totalCount = await query.CountAsync();

        var ordered = descending ? query.OrderByDescending(orderBy) : query.OrderBy(orderBy);

        var key = _ctx.Model.FindEntityType(typeof(T))?.FindPrimaryKey();
        if (key != null && key.Properties.Count == 1 && key.Properties[0].ClrType == typeof(Guid))
        {
            var keyName = key.Properties[0].Name;
            ordered = ordered.ThenBy(e => EF.Property<Guid>(e, keyName));
        }

        var items = await ordered
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (items, totalCount);
    }

}
