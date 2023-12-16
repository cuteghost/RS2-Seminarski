using eBooking.Model.Domain;
using Microsoft.EntityFrameworkCore;

namespace eBooking.Services.Database
{
    public partial class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {

        }
        public DbSet<User> Users { get; set; }
        public DbSet<City> Cities { get; set; }
    }
}
