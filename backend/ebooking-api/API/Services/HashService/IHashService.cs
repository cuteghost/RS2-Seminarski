namespace Services.HashService
{
    public interface IHashService
    {
        public string Hash(string clearTextPassword);
    }
}