using System.Security.Cryptography;

namespace Authentication.Services.HashService
{
    /// <summary>
    /// PBKDF2-HMAC-SHA256 sa nasumičnom soli po lozinci.
    ///
    /// <para>
    /// Ranije se koristio goli SHA256 bez soli: isti tekst je uvijek davao isti heš, pa su se
    /// jednake lozinke prepoznavale u bazi, a heš se probijao gotovim rainbow tabelama jer je
    /// SHA256 namjerno brz. PBKDF2 rješava oboje — so razdvaja jednake lozinke, a broj iteracija
    /// čini provjeru dovoljno sporom da pogađanje ne bude isplativo.
    /// </para>
    ///
    /// <para>
    /// Zapis ima oblik <c>pbkdf2-sha256$iteracije$so$heš</c>, gdje su so i heš u Base64. Broj
    /// iteracija je dio zapisa da bi se u budućnosti mogao povećati bez gubitka starih lozinki.
    /// </para>
    /// </summary>
    public class HashService : IHashService
    {
        private const string Algorithm = "pbkdf2-sha256";

        /// <summary>Preporuka OWASP-a za PBKDF2-HMAC-SHA256.</summary>
        private const int Iterations = 210_000;

        private const int SaltSizeInBytes = 16;
        private const int KeySizeInBytes = 32;
        private const char SegmentSeparator = '$';
        private const int SegmentCount = 4;

        public string Hash(string clearTextPassword)
        {
            if (string.IsNullOrEmpty(clearTextPassword))
                throw new ArgumentException("Password must not be empty.", nameof(clearTextPassword));

            var salt = RandomNumberGenerator.GetBytes(SaltSizeInBytes);
            var key = Rfc2898DeriveBytes.Pbkdf2(
                clearTextPassword, salt, Iterations, HashAlgorithmName.SHA256, KeySizeInBytes);

            return string.Join(
                SegmentSeparator,
                Algorithm,
                Iterations,
                Convert.ToBase64String(salt),
                Convert.ToBase64String(key));
        }

        public bool Verify(string clearTextPassword, string storedHash)
        {
            if (string.IsNullOrEmpty(clearTextPassword) || string.IsNullOrEmpty(storedHash))
                return false;

            var segments = storedHash.Split(SegmentSeparator);
            if (segments.Length != SegmentCount || segments[0] != Algorithm)
                return false;

            if (!int.TryParse(segments[1], out var iterations) || iterations < 1)
                return false;

            byte[] salt;
            byte[] expectedKey;
            try
            {
                salt = Convert.FromBase64String(segments[2]);
                expectedKey = Convert.FromBase64String(segments[3]);
            }
            catch (FormatException)
            {
                // Zapis nije u očekivanom Base64 obliku - tretira se kao neispravna lozinka,
                // a ne kao pad prijave.
                return false;
            }

            var actualKey = Rfc2898DeriveBytes.Pbkdf2(
                clearTextPassword, salt, iterations, HashAlgorithmName.SHA256, expectedKey.Length);

            // Poređenje u konstantnom vremenu da dužina podudaranja ne curi kroz vrijeme odgovora.
            return CryptographicOperations.FixedTimeEquals(actualKey, expectedKey);
        }
    }
}
