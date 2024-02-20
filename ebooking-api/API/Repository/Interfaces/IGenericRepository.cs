using System.Linq.Expressions;

namespace eBooking.Services.Interfaces;

public interface IGenericRepository<T> where T : class
{
    public Task<bool> Add(T model);

    public Task<bool> Update(Expression<Func<T, bool>> predicate, T model);

    public Task<bool> Delete(Expression<Func<T, bool>> predicate);

    public Task<T> GetById(int id);

    public Task<IEnumerable<T>> GetAll(params Expression<Func<T, object>>[] includeProperties);


}
