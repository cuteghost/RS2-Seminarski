using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class AddReservationStatus : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Status",
                table: "Reservations",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "StatusChangedAt",
                table: "Reservations",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "StatusReason",
                table: "Reservations",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "ReservationStatusHistory",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ReservationId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    FromStatus = table.Column<int>(type: "int", nullable: true),
                    ToStatus = table.Column<int>(type: "int", nullable: false),
                    ChangedByUserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ChangedByRole = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    ChangedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Reason = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReservationStatusHistory", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ReservationStatusHistory_Reservations_ReservationId",
                        column: x => x.ReservationId,
                        principalTable: "Reservations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000001"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2025, 12, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000002"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 2, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000003"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 4, 29, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000004"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 6, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000005"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 1, new DateTime(2026, 8, 31, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000006"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2025, 12, 29, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000007"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 3, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000008"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 5, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000009"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 7, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000010"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 2, new DateTime(2026, 9, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000011"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000012"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 3, 4, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000013"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 5, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000014"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 7, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000015"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 2, new DateTime(2026, 9, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000016"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 1, 4, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000017"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 3, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000018"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 5, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000019"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 7, 9, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000020"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 3, new DateTime(2026, 9, 9, 0, 0, 0, 0, DateTimeKind.Unspecified), "Gost je otkazao putovanje." });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000021"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 1, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000022"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 3, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000023"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 5, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000024"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 7, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000025"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 1, new DateTime(2026, 9, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000026"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000027"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 3, 13, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000028"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 5, 14, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000029"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 7, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000030"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 2, new DateTime(2026, 9, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000031"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 1, 13, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000032"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 3, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000033"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 5, 17, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000034"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 7, 18, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000035"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 2, new DateTime(2026, 9, 18, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000036"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 1, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000037"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 3, 19, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000038"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 5, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000039"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 7, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000040"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 3, new DateTime(2026, 9, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), "Gost je otkazao putovanje." });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000041"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 1, 19, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000042"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 3, 22, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000043"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 5, 23, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000044"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 7, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000045"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 1, new DateTime(2026, 9, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000046"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 1, 22, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000047"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 3, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000048"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 5, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000049"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 7, 27, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000050"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 2, new DateTime(2026, 9, 27, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000051"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 1, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000052"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 3, 28, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000053"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 5, 29, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000054"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 7, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000055"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 2, new DateTime(2026, 9, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000056"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 1, 28, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000057"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 3, 31, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000058"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000059"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 5, new DateTime(2026, 8, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000060"),
                columns: new[] { "Status", "StatusChangedAt", "StatusReason" },
                values: new object[] { 3, new DateTime(2026, 10, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), "Gost je otkazao putovanje." });

            migrationBuilder.CreateIndex(
                name: "IX_ReservationStatusHistory_ReservationId",
                table: "ReservationStatusHistory",
                column: "ReservationId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ReservationStatusHistory");

            migrationBuilder.DropColumn(
                name: "Status",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "StatusChangedAt",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "StatusReason",
                table: "Reservations");
        }
    }
}
