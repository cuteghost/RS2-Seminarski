using Models.Domain;
using Microsoft.EntityFrameworkCore;

namespace Database;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {

    }
    public DbSet<City> Cities { get; set; }
    public DbSet<Country> Countries { get; set; }
    public DbSet<Location> Locations { get; set; }
    public DbSet<User> Users { get; set; }
    public DbSet<Administrator> Administrators { get; set; }
    public DbSet<Partner> Partners { get; set; }
    public DbSet<Customer> Customers { get; set; }
    public DbSet<Accommodation> Accommodations { get; set;}
    public DbSet<AccommodationDetails> AccommodationDetails { get; set; }
}
