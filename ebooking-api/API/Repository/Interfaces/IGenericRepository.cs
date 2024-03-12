using System.Linq.Expressions;

namespace eBooking.Services.Interfaces;

public interface IGenericRepository<T> where T : class
{
    public Task<bool> Add(T model);

    public Task<bool> Update(Expression<Func<T, bool>> predicate, T model);

    public Task<bool> Delete(Expression<Func<T, bool>> predicate);

    public Task<T> GetById(Expression<Func<T, bool>> predicate, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);

    public Task<IEnumerable<T>> GetAll(bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);


}
