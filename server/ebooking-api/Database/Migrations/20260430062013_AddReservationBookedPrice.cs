using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class AddReservationBookedPrice : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "PricePerNight",
                table: "Reservations",
                type: "decimal(10,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "TotalPrice",
                table: "Reservations",
                type: "decimal(10,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.Sql(@"
UPDATE r
SET r.PricePerNight = CAST(a.PricePerNight AS decimal(10,2)),
    r.TotalPrice = CAST(a.PricePerNight AS decimal(10,2)) * DATEDIFF(day, r.StartDate, r.EndDate)
FROM Reservations r
INNER JOIN Accommodations a ON a.Id = r.AccommodationId
WHERE r.TotalPrice = 0;");

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000001"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 180m, 360m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000002"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 180m, 540m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000003"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 180m, 720m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000004"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 180m, 900m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000005"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 180m, 1080m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000006"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 65m, 195m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000007"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 65m, 260m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000008"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 65m, 325m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000009"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 65m, 390m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000010"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 65m, 130m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000011"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 120m, 480m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000012"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 120m, 600m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000013"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 120m, 720m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000014"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 120m, 240m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000015"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 120m, 360m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000016"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 25m, 125m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000017"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 25m, 150m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000018"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 25m, 50m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000019"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 25m, 75m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000020"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 25m, 100m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000021"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 210m, 1260m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000022"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 210m, 420m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000023"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 210m, 630m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000024"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 210m, 840m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000025"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 210m, 1050m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000026"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 95m, 190m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000027"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 95m, 285m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000028"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 95m, 380m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000029"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 95m, 475m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000030"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 95m, 570m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000031"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 70m, 210m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000032"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 70m, 280m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000033"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 70m, 350m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000034"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 70m, 420m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000035"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 70m, 140m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000036"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 240m, 960m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000037"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 240m, 1200m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000038"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 240m, 1440m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000039"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 240m, 480m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000040"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 240m, 720m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000041"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 110m, 550m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000042"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 110m, 660m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000043"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 110m, 220m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000044"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 110m, 330m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000045"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 110m, 440m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000046"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 320m, 1920m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000047"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 320m, 640m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000048"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 320m, 960m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000049"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 320m, 1280m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000050"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 320m, 1600m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000051"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 140m, 280m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000052"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 140m, 420m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000053"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 140m, 560m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000054"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 140m, 700m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000055"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 140m, 840m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000056"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 260m, 780m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000057"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 260m, 1040m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000058"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 260m, 1300m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000059"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 260m, 1560m });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000060"),
                columns: new[] { "PricePerNight", "TotalPrice" },
                values: new object[] { 260m, 520m });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PricePerNight",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "TotalPrice",
                table: "Reservations");
        }
    }
}
