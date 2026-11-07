using Models.Domain;
using Microsoft.EntityFrameworkCore;
using Database.Data.Seed;

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
    public DbSet<Accommodation> Accommodations { get; set; }
    public DbSet<AccommodationDetails> AccommodationDetails { get; set; }
    public DbSet<Reservation> Reservations { get; set; }
    public DbSet<Message> Messages { get; set; }
    public DbSet<Chat> Chats { get; set; }
    public DbSet<Review> Reviews { get; set; }
    public DbSet<ReservationStatusHistory> ReservationStatusHistory { get; set; }
    public DbSet<Payment> Payments { get; set; }
    public DbSet<AccommodationType> AccommodationTypes { get; set; }
    public DbSet<Amenity> Amenities { get; set; }
    public DbSet<AccommodationDetailsAmenity> AccommodationDetailsAmenities { get; set; }
    public DbSet<ReviewImage> ReviewImages { get; set; }
    public DbSet<Notification> Notifications { get; set; }
    public DbSet<PasswordResetToken> PasswordResetTokens { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Veza se opisuje izričito da dodavanje kolekcije Accommodation.Reservations ne bi
        // stvorilo drugi, sjenoviti strani ključ pored postojećeg Reservation.AccommodationId.
        modelBuilder.Entity<Reservation>()
            .HasOne(r => r.accommodation)
            .WithMany(a => a.Reservations)
            .HasForeignKey(r => r.AccommodationId);

        modelBuilder.Entity<ReservationStatusHistory>()
            .HasOne(h => h.Reservation)
            .WithMany()
            .HasForeignKey(h => h.ReservationId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ReservationStatusHistory>()
            .HasIndex(h => h.ReservationId);

        modelBuilder.Entity<Payment>()
            .HasOne(p => p.Reservation)
            .WithMany()
            .HasForeignKey(p => p.ReservationId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Payment>()
            .HasIndex(p => p.ReservationId);

        modelBuilder.Entity<Payment>()
            .HasIndex(p => p.ProviderOrderId)
            .IsUnique()
            .HasFilter("[ProviderOrderId] IS NOT NULL");

        modelBuilder.Entity<AccommodationDetailsAmenity>()
            .HasKey(x => new { x.AccommodationDetailsId, x.AmenityId });

        modelBuilder.Entity<AccommodationDetailsAmenity>()
            .HasOne(x => x.AccommodationDetails)
            .WithMany(d => d.AccommodationDetailsAmenities)
            .HasForeignKey(x => x.AccommodationDetailsId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<AccommodationDetailsAmenity>()
            .HasOne(x => x.Amenity)
            .WithMany(a => a.AccommodationDetailsAmenities)
            .HasForeignKey(x => x.AmenityId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<AccommodationType>()
            .HasIndex(t => t.Name)
            .IsUnique()
            .HasFilter("[IsDeleted] = 0");

        modelBuilder.Entity<Amenity>()
            .HasIndex(a => a.Code)
            .IsUnique()
            .HasFilter("[IsDeleted] = 0");

        modelBuilder.Entity<Chat>()
            .HasOne(c => c.User1)
            .WithMany()
            .HasForeignKey(c => c.User1Id)
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<Chat>()
            .HasOne(c => c.User2)
            .WithMany()
            .HasForeignKey(c => c.User2Id)
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<Message>()
            .HasOne(m => m.Chat)
            .WithMany(c => c.Messages)
            .HasForeignKey(m => m.ChatId)
            .OnDelete(DeleteBehavior.Cascade);
        modelBuilder.Entity<Country>()
            .HasIndex(c => c.Name)
            .IsUnique()
            .HasFilter("[IsDeleted] = 0");

        modelBuilder.Entity<Review>()
            .HasOne(r => r.Reservation)
            .WithMany()
            .HasForeignKey(r => r.ReservationId)
            .OnDelete(DeleteBehavior.NoAction);

        modelBuilder.Entity<Review>()
            .HasIndex(r => r.ReservationId)
            .IsUnique()
            .HasFilter("[ReservationId] IS NOT NULL AND [IsDeleted] = 0");

        modelBuilder.Entity<ReviewImage>()
            .HasOne(i => i.Review)
            .WithOne(r => r.Image)
            .HasForeignKey<ReviewImage>(i => i.ReviewId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Notification>()
            .HasOne(n => n.User)
            .WithMany()
            .HasForeignKey(n => n.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Notification>()
            .HasIndex(n => new { n.UserId, n.IsRead, n.CreatedAt });

        modelBuilder.Entity<PasswordResetToken>()
            .HasOne(t => t.User)
            .WithMany()
            .HasForeignKey(t => t.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<PasswordResetToken>()
            .HasIndex(t => new { t.UserId, t.UsedAt });

        modelBuilder.Entity<Accommodation>()
            .HasIndex(a => a.IsPromoted)
            .HasFilter("[IsPromoted] = 1 AND [IsDeleted] = 0");

        SeedData.Apply(modelBuilder);

        base.OnModelCreating(modelBuilder);
    }
}
