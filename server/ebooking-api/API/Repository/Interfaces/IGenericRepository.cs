using System.Linq.Expressions;

namespace Repository.Interfaces;

public interface IGenericRepository<T> where T : class
{
    public Task<bool> Add(T model);

    public Task<bool> Update(Expression<Func<T, bool>> predicate, T model, params Expression<Func<T, object>>[] includeProperties);

    public Task<bool> Delete(Expression<Func<T, bool>> predicate);

    public Task<T> Get(Expression<Func<T, bool>> predicate, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);

    public Task<IEnumerable<T>> GetAll(bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);

    public Task<IEnumerable<T>> GetAll(Expression<Func<T, bool>> predicate, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);

    /// <summary>
    /// Broj zapisa koji zadovoljavaju uslov. Broji se u SQL-u (<c>COUNT</c>), bez učitavanja
    /// redova - koristi se za provjeru „zapis je u upotrebi" prije brisanja.
    /// </summary>
    public Task<int> Count(Expression<Func<T, bool>> predicate, bool includeDeleted = false);

    /// <summary>
    /// Postoji li ijedan zapis koji zadovoljava uslov. Prevodi se u <c>EXISTS</c>.
    /// </summary>
    public Task<bool> Any(Expression<Func<T, bool>> predicate, bool includeDeleted = false);

    public Task<List<TResult>> Project<TResult>(Expression<Func<T, TResult>> selector, bool includeDeleted = false);

    public Task<List<TResult>> Project<TResult>(Expression<Func<T, bool>> predicate, Expression<Func<T, TResult>> selector, bool includeDeleted = false);

    public Task<(IEnumerable<T> Items, int TotalCount)> GetPaged(int page, int pageSize, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);

    /// <summary>
    /// Ista stranica, ali sa filterom. Predikat ide u <c>Where</c> nad <c>IQueryable</c> prije
    /// <c>Skip</c>/<c>Take</c>, pa i filtriranje i brojanje ostaju u SQL-u.
    /// </summary>
    public Task<(IEnumerable<T> Items, int TotalCount)> GetPaged(Expression<Func<T, bool>> predicate, int page, int pageSize, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);

    public Task<(IEnumerable<T> Items, int TotalCount)> GetPaged<TKey>(Expression<Func<T, bool>> predicate, Expression<Func<T, TKey>> orderBy, bool descending, int page, int pageSize, bool includeDeleted = false, params Expression<Func<T, object>>[] includeProperties);
}
