namespace eBooking.Services.Interfaces;

public interface ICRUDService<T, TSearch, TInsert, TUpdate>
                 : IService<T, TSearch> where T : class where TSearch : class where TInsert : class where TUpdate : class
{
    T Insert(TInsert insert);

    T Update(int id, TUpdate update);
}
