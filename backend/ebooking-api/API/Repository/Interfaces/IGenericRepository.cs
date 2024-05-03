using System.Linq.Expressions;

namespace Repository.Interfaces;

public interface IGenericRepository<T> where T : class
{
    public Task<bool> Add(T model);

    public Task<bool> Update(Expression<Func<T, bool>> predicate, T model);

    public Task<bool> Delete(Expression<Func<T, bool>> predicate);

    public Task<T> Get(Expression<Func<T, bool>> predicate, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);

    public Task<IEnumerable<T>> GetAll(bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);

    public Task<IEnumerable<T>> GetAll(Expression<Func<T, bool>> predicate, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);


    //public Task<T> Get(Expression<Func<T, bool>> predicate, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);


}
