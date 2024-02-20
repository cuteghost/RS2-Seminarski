using System.Security.Cryptography;
using System.Text;

namespace Services.HashService
{
    public class HashService : IHashService
    {
        public HashService()
        {
            var test = "test";
        }
        public string Hash(string clearTextPassword)
        {
            StringBuilder Sb = new StringBuilder();


            using (SHA256 hash = SHA256Managed.Create())
            {

                Encoding enc = Encoding.UTF8;

                Byte[] result = hash.ComputeHash(enc.GetBytes(clearTextPassword));


                foreach (Byte b in result)

                    Sb.Append(b.ToString("x2"));

            }
            return Sb.ToString();
        }
    }
}