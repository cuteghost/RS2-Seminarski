namespace eBooking.Services.Interfaces;

public interface IService<T, TSearch> where T : class where TSearch : class
{
    IEnumerable<T> Get(TSearch search = null);
    T GetById(int id);
}