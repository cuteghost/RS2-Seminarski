using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class AugustReviewFixes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Accommodations",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsPromoted",
                table: "Accommodations",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "PromotedAt",
                table: "Accommodations",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<TimeOnly>(
                name: "CheckInTime",
                table: "Reservations",
                type: "time",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ReservationId",
                table: "Reviews",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Notifications",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Type = table.Column<int>(type: "int", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    Body = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false),
                    RelatedEntityId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsRead = table.Column<bool>(type: "bit", nullable: false),
                    ReadAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Notifications", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Notifications_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PasswordResetTokens",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    CodeHash = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UsedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    FailedAttempts = table.Column<int>(type: "int", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PasswordResetTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PasswordResetTokens_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ReviewImages",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ReviewId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReviewImages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ReviewImages_Reviews_ReviewId",
                        column: x => x.ReviewId,
                        principalTable: "Reviews",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000001"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000001"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000002"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000002"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000003"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000006"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000004"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000007"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000005"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000011"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000006"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000012"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000007"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000016"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000008"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000017"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000009"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000021"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000010"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000022"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000011"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000026"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000012"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000027"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000013"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000031"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000014"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000032"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000015"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000036"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000016"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000037"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000017"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000041"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000018"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000042"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000019"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000046"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000020"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000047"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000021"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000051"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000022"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000052"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000023"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000056"));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000024"),
                column: "ReservationId",
                value: new Guid("0000000b-0000-0000-0000-000000000057"));

            migrationBuilder.Sql(@"
WITH CompletedStays AS (
    SELECT r.Id, r.CustomerId, r.AccommodationId,
           ROW_NUMBER() OVER (PARTITION BY r.CustomerId, r.AccommodationId ORDER BY r.EndDate, r.Id) AS Position
    FROM Reservations r
    WHERE r.Status = 5
      AND NOT EXISTS (SELECT 1 FROM Reviews linked WHERE linked.ReservationId = r.Id)
),
UnlinkedReviews AS (
    SELECT v.Id, v.CustomerId, v.AccommodationId,
           ROW_NUMBER() OVER (PARTITION BY v.CustomerId, v.AccommodationId ORDER BY v.Id) AS Position
    FROM Reviews v
    WHERE v.ReservationId IS NULL
)
UPDATE review
SET review.ReservationId = stay.Id
FROM Reviews review
JOIN UnlinkedReviews unlinked ON unlinked.Id = review.Id
JOIN CompletedStays stay
  ON stay.CustomerId = unlinked.CustomerId
 AND stay.AccommodationId = unlinked.AccommodationId
 AND stay.Position = unlinked.Position;");

            migrationBuilder.Sql(@"
UPDATE a
SET a.CreatedAt = COALESCE(
        DATEADD(day, -14, (SELECT MIN(r.StartDate) FROM Reservations r WHERE r.AccommodationId = a.Id)),
        u.Joined,
        SYSUTCDATETIME())
FROM Accommodations a
LEFT JOIN Partners p ON p.Id = a.OwnerId
LEFT JOIN Users u ON u.Id = p.UserId
WHERE a.CreatedAt IS NULL;");

            migrationBuilder.CreateIndex(
                name: "IX_Accommodations_IsPromoted",
                table: "Accommodations",
                column: "IsPromoted",
                filter: "[IsPromoted] = 1 AND [IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_ReservationId",
                table: "Reviews",
                column: "ReservationId",
                unique: true,
                filter: "[ReservationId] IS NOT NULL AND [IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_UserId_IsRead_CreatedAt",
                table: "Notifications",
                columns: new[] { "UserId", "IsRead", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_PasswordResetTokens_UserId_UsedAt",
                table: "PasswordResetTokens",
                columns: new[] { "UserId", "UsedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_ReviewImages_ReviewId",
                table: "ReviewImages",
                column: "ReviewId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Reviews_Reservations_ReservationId",
                table: "Reviews",
                column: "ReservationId",
                principalTable: "Reservations",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Reviews_Reservations_ReservationId",
                table: "Reviews");

            migrationBuilder.DropTable(
                name: "Notifications");

            migrationBuilder.DropTable(
                name: "PasswordResetTokens");

            migrationBuilder.DropTable(
                name: "ReviewImages");

            migrationBuilder.DropIndex(
                name: "IX_Reviews_ReservationId",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_Accommodations_IsPromoted",
                table: "Accommodations");

            migrationBuilder.DropColumn(
                name: "ReservationId",
                table: "Reviews");

            migrationBuilder.DropColumn(
                name: "CheckInTime",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Accommodations");

            migrationBuilder.DropColumn(
                name: "IsPromoted",
                table: "Accommodations");

            migrationBuilder.DropColumn(
                name: "PromotedAt",
                table: "Accommodations");
        }
    }
}
