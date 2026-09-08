namespace Authentication.Services.HashService
{
    public interface IHashService
    {
        /// <summary>
        /// Vraća zapis lozinke spreman za upis u bazu. Isti tekst daje različit rezultat pri
        /// svakom pozivu jer se za svaku lozinku generiše nova so, pa se dva zapisa nikad ne
        /// smiju porediti znak po znak — za provjeru postoji <see cref="Verify"/>.
        /// </summary>
        string Hash(string clearTextPassword);

        /// <summary>
        /// Provjerava da li uneseni tekst odgovara ranije sačuvanom zapisu lozinke.
        /// Vraća <c>false</c> i kad je zapis prazan ili u formatu koji servis ne prepoznaje.
        /// </summary>
        bool Verify(string clearTextPassword, string storedHash);
    }
}
