using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class AddAccommodationReferenceTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "AccommodationTypeId",
                table: "Accommodations",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.CreateTable(
                name: "AccommodationTypes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AccommodationTypes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Amenities",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Amenities", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AccommodationDetailsAmenities",
                columns: table => new
                {
                    AccommodationDetailsId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    AmenityId = table.Column<Guid>(type: "uniqueidentifier", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AccommodationDetailsAmenities", x => new { x.AccommodationDetailsId, x.AmenityId });
                    table.ForeignKey(
                        name: "FK_AccommodationDetailsAmenities_AccommodationDetails_AccommodationDetailsId",
                        column: x => x.AccommodationDetailsId,
                        principalTable: "AccommodationDetails",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AccommodationDetailsAmenities_Amenities_AmenityId",
                        column: x => x.AmenityId,
                        principalTable: "Amenities",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "AccommodationTypes",
                columns: new[] { "Id", "IsDeleted", "Name", "SortOrder" },
                values: new object[,]
                {
                    { new Guid("0000000f-0000-0000-0000-000000000001"), false, "Kuća", 1 },
                    { new Guid("0000000f-0000-0000-0000-000000000002"), false, "Hotel", 2 },
                    { new Guid("0000000f-0000-0000-0000-000000000003"), false, "Resort", 3 },
                    { new Guid("0000000f-0000-0000-0000-000000000004"), false, "Apartman", 4 },
                    { new Guid("0000000f-0000-0000-0000-000000000005"), false, "Vila", 5 },
                    { new Guid("0000000f-0000-0000-0000-000000000006"), false, "Hostel", 6 },
                    { new Guid("0000000f-0000-0000-0000-000000000007"), false, "Vikendica", 7 },
                    { new Guid("0000000f-0000-0000-0000-000000000008"), false, "Penthouse", 8 }
                });

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000001"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000005"));

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000002"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000004"));

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000003"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000002"));

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000004"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000006"));

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000005"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000008"));

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000006"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000001"));

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000007"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000004"));

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000008"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000005"));

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000009"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000004"));

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000010"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000002"));

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000011"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000007"));

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000012"),
                column: "AccommodationTypeId",
                value: new Guid("0000000f-0000-0000-0000-000000000003"));

            migrationBuilder.InsertData(
                table: "Amenities",
                columns: new[] { "Id", "Code", "IsDeleted", "Name", "SortOrder" },
                values: new object[,]
                {
                    { new Guid("00000010-0000-0000-0000-000000000001"), "Bathub", false, "Kada", 1 },
                    { new Guid("00000010-0000-0000-0000-000000000002"), "Balcony", false, "Balkon", 2 },
                    { new Guid("00000010-0000-0000-0000-000000000003"), "PrivateBathroom", false, "Privatno kupatilo", 3 },
                    { new Guid("00000010-0000-0000-0000-000000000004"), "AC", false, "Klima uređaj", 4 },
                    { new Guid("00000010-0000-0000-0000-000000000005"), "Terrace", false, "Terasa", 5 },
                    { new Guid("00000010-0000-0000-0000-000000000006"), "Kitchen", false, "Kuhinja", 6 },
                    { new Guid("00000010-0000-0000-0000-000000000007"), "PrivatePool", false, "Privatni bazen", 7 },
                    { new Guid("00000010-0000-0000-0000-000000000008"), "CoffeeMachine", false, "Aparat za kafu", 8 },
                    { new Guid("00000010-0000-0000-0000-000000000009"), "View", false, "Pogled", 9 },
                    { new Guid("00000010-0000-0000-0000-000000000010"), "SeaView", false, "Pogled na more", 10 },
                    { new Guid("00000010-0000-0000-0000-000000000011"), "WashingMachine", false, "Mašina za veš", 11 },
                    { new Guid("00000010-0000-0000-0000-000000000012"), "SpaTub", false, "Hidromasažna kada", 12 },
                    { new Guid("00000010-0000-0000-0000-000000000013"), "SoundProof", false, "Zvučna izolacija", 13 },
                    { new Guid("00000010-0000-0000-0000-000000000014"), "Breakfast", false, "Doručak", 14 }
                });

            migrationBuilder.InsertData(
                table: "AccommodationDetailsAmenities",
                columns: new[] { "AccommodationDetailsId", "AmenityId" },
                values: new object[,]
                {
                    { new Guid("00000009-0000-0000-0000-000000000001"), new Guid("00000010-0000-0000-0000-000000000001") },
                    { new Guid("00000009-0000-0000-0000-000000000001"), new Guid("00000010-0000-0000-0000-000000000002") },
                    { new Guid("00000009-0000-0000-0000-000000000001"), new Guid("00000010-0000-0000-0000-000000000003") },
                    { new Guid("00000009-0000-0000-0000-000000000001"), new Guid("00000010-0000-0000-0000-000000000004") },
                    { new Guid("00000009-0000-0000-0000-000000000001"), new Guid("00000010-0000-0000-0000-000000000005") },
                    { new Guid("00000009-0000-0000-0000-000000000001"), new Guid("00000010-0000-0000-0000-000000000006") },
                    { new Guid("00000009-0000-0000-0000-000000000001"), new Guid("00000010-0000-0000-0000-000000000007") },
                    { new Guid("00000009-0000-0000-0000-000000000001"), new Guid("00000010-0000-0000-0000-000000000008") },
                    { new Guid("00000009-0000-0000-0000-000000000001"), new Guid("00000010-0000-0000-0000-000000000009") },
                    { new Guid("00000009-0000-0000-0000-000000000001"), new Guid("00000010-0000-0000-0000-000000000011") },
                    { new Guid("00000009-0000-0000-0000-000000000001"), new Guid("00000010-0000-0000-0000-000000000012") },
                    { new Guid("00000009-0000-0000-0000-000000000002"), new Guid("00000010-0000-0000-0000-000000000002") },
                    { new Guid("00000009-0000-0000-0000-000000000002"), new Guid("00000010-0000-0000-0000-000000000003") },
                    { new Guid("00000009-0000-0000-0000-000000000002"), new Guid("00000010-0000-0000-0000-000000000004") },
                    { new Guid("00000009-0000-0000-0000-000000000002"), new Guid("00000010-0000-0000-0000-000000000006") },
                    { new Guid("00000009-0000-0000-0000-000000000002"), new Guid("00000010-0000-0000-0000-000000000008") },
                    { new Guid("00000009-0000-0000-0000-000000000002"), new Guid("00000010-0000-0000-0000-000000000009") },
                    { new Guid("00000009-0000-0000-0000-000000000002"), new Guid("00000010-0000-0000-0000-000000000011") },
                    { new Guid("00000009-0000-0000-0000-000000000002"), new Guid("00000010-0000-0000-0000-000000000013") },
                    { new Guid("00000009-0000-0000-0000-000000000003"), new Guid("00000010-0000-0000-0000-000000000001") },
                    { new Guid("00000009-0000-0000-0000-000000000003"), new Guid("00000010-0000-0000-0000-000000000002") },
                    { new Guid("00000009-0000-0000-0000-000000000003"), new Guid("00000010-0000-0000-0000-000000000003") },
                    { new Guid("00000009-0000-0000-0000-000000000003"), new Guid("00000010-0000-0000-0000-000000000004") },
                    { new Guid("00000009-0000-0000-0000-000000000003"), new Guid("00000010-0000-0000-0000-000000000008") },
                    { new Guid("00000009-0000-0000-0000-000000000003"), new Guid("00000010-0000-0000-0000-000000000009") },
                    { new Guid("00000009-0000-0000-0000-000000000003"), new Guid("00000010-0000-0000-0000-000000000013") },
                    { new Guid("00000009-0000-0000-0000-000000000003"), new Guid("00000010-0000-0000-0000-000000000014") },
                    { new Guid("00000009-0000-0000-0000-000000000004"), new Guid("00000010-0000-0000-0000-000000000004") },
                    { new Guid("00000009-0000-0000-0000-000000000004"), new Guid("00000010-0000-0000-0000-000000000006") },
                    { new Guid("00000009-0000-0000-0000-000000000004"), new Guid("00000010-0000-0000-0000-000000000011") },
                    { new Guid("00000009-0000-0000-0000-000000000005"), new Guid("00000010-0000-0000-0000-000000000001") },
                    { new Guid("00000009-0000-0000-0000-000000000005"), new Guid("00000010-0000-0000-0000-000000000002") },
                    { new Guid("00000009-0000-0000-0000-000000000005"), new Guid("00000010-0000-0000-0000-000000000003") },
                    { new Guid("00000009-0000-0000-0000-000000000005"), new Guid("00000010-0000-0000-0000-000000000004") },
                    { new Guid("00000009-0000-0000-0000-000000000005"), new Guid("00000010-0000-0000-0000-000000000005") },
                    { new Guid("00000009-0000-0000-0000-000000000005"), new Guid("00000010-0000-0000-0000-000000000006") },
                    { new Guid("00000009-0000-0000-0000-000000000005"), new Guid("00000010-0000-0000-0000-000000000008") },
                    { new Guid("00000009-0000-0000-0000-000000000005"), new Guid("00000010-0000-0000-0000-000000000009") },
                    { new Guid("00000009-0000-0000-0000-000000000005"), new Guid("00000010-0000-0000-0000-000000000011") },
                    { new Guid("00000009-0000-0000-0000-000000000005"), new Guid("00000010-0000-0000-0000-000000000012") },
                    { new Guid("00000009-0000-0000-0000-000000000005"), new Guid("00000010-0000-0000-0000-000000000013") },
                    { new Guid("00000009-0000-0000-0000-000000000006"), new Guid("00000010-0000-0000-0000-000000000002") },
                    { new Guid("00000009-0000-0000-0000-000000000006"), new Guid("00000010-0000-0000-0000-000000000003") },
                    { new Guid("00000009-0000-0000-0000-000000000006"), new Guid("00000010-0000-0000-0000-000000000005") },
                    { new Guid("00000009-0000-0000-0000-000000000006"), new Guid("00000010-0000-0000-0000-000000000006") },
                    { new Guid("00000009-0000-0000-0000-000000000006"), new Guid("00000010-0000-0000-0000-000000000009") },
                    { new Guid("00000009-0000-0000-0000-000000000006"), new Guid("00000010-0000-0000-0000-000000000011") },
                    { new Guid("00000009-0000-0000-0000-000000000007"), new Guid("00000010-0000-0000-0000-000000000002") },
                    { new Guid("00000009-0000-0000-0000-000000000007"), new Guid("00000010-0000-0000-0000-000000000003") },
                    { new Guid("00000009-0000-0000-0000-000000000007"), new Guid("00000010-0000-0000-0000-000000000004") },
                    { new Guid("00000009-0000-0000-0000-000000000007"), new Guid("00000010-0000-0000-0000-000000000006") },
                    { new Guid("00000009-0000-0000-0000-000000000007"), new Guid("00000010-0000-0000-0000-000000000008") },
                    { new Guid("00000009-0000-0000-0000-000000000007"), new Guid("00000010-0000-0000-0000-000000000009") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000001") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000002") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000003") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000004") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000005") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000006") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000007") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000008") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000009") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000010") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000011") },
                    { new Guid("00000009-0000-0000-0000-000000000008"), new Guid("00000010-0000-0000-0000-000000000012") },
                    { new Guid("00000009-0000-0000-0000-000000000009"), new Guid("00000010-0000-0000-0000-000000000002") },
                    { new Guid("00000009-0000-0000-0000-000000000009"), new Guid("00000010-0000-0000-0000-000000000003") },
                    { new Guid("00000009-0000-0000-0000-000000000009"), new Guid("00000010-0000-0000-0000-000000000004") },
                    { new Guid("00000009-0000-0000-0000-000000000009"), new Guid("00000010-0000-0000-0000-000000000006") },
                    { new Guid("00000009-0000-0000-0000-000000000009"), new Guid("00000010-0000-0000-0000-000000000008") },
                    { new Guid("00000009-0000-0000-0000-000000000009"), new Guid("00000010-0000-0000-0000-000000000009") },
                    { new Guid("00000009-0000-0000-0000-000000000009"), new Guid("00000010-0000-0000-0000-000000000010") },
                    { new Guid("00000009-0000-0000-0000-000000000009"), new Guid("00000010-0000-0000-0000-000000000011") },
                    { new Guid("00000009-0000-0000-0000-000000000009"), new Guid("00000010-0000-0000-0000-000000000013") },
                    { new Guid("00000009-0000-0000-0000-000000000010"), new Guid("00000010-0000-0000-0000-000000000001") },
                    { new Guid("00000009-0000-0000-0000-000000000010"), new Guid("00000010-0000-0000-0000-000000000002") },
                    { new Guid("00000009-0000-0000-0000-000000000010"), new Guid("00000010-0000-0000-0000-000000000003") },
                    { new Guid("00000009-0000-0000-0000-000000000010"), new Guid("00000010-0000-0000-0000-000000000004") },
                    { new Guid("00000009-0000-0000-0000-000000000010"), new Guid("00000010-0000-0000-0000-000000000005") },
                    { new Guid("00000009-0000-0000-0000-000000000010"), new Guid("00000010-0000-0000-0000-000000000008") },
                    { new Guid("00000009-0000-0000-0000-000000000010"), new Guid("00000010-0000-0000-0000-000000000009") },
                    { new Guid("00000009-0000-0000-0000-000000000010"), new Guid("00000010-0000-0000-0000-000000000010") },
                    { new Guid("00000009-0000-0000-0000-000000000010"), new Guid("00000010-0000-0000-0000-000000000012") },
                    { new Guid("00000009-0000-0000-0000-000000000010"), new Guid("00000010-0000-0000-0000-000000000013") },
                    { new Guid("00000009-0000-0000-0000-000000000010"), new Guid("00000010-0000-0000-0000-000000000014") },
                    { new Guid("00000009-0000-0000-0000-000000000011"), new Guid("00000010-0000-0000-0000-000000000001") },
                    { new Guid("00000009-0000-0000-0000-000000000011"), new Guid("00000010-0000-0000-0000-000000000003") },
                    { new Guid("00000009-0000-0000-0000-000000000011"), new Guid("00000010-0000-0000-0000-000000000005") },
                    { new Guid("00000009-0000-0000-0000-000000000011"), new Guid("00000010-0000-0000-0000-000000000006") },
                    { new Guid("00000009-0000-0000-0000-000000000011"), new Guid("00000010-0000-0000-0000-000000000008") },
                    { new Guid("00000009-0000-0000-0000-000000000011"), new Guid("00000010-0000-0000-0000-000000000009") },
                    { new Guid("00000009-0000-0000-0000-000000000011"), new Guid("00000010-0000-0000-0000-000000000011") },
                    { new Guid("00000009-0000-0000-0000-000000000012"), new Guid("00000010-0000-0000-0000-000000000001") },
                    { new Guid("00000009-0000-0000-0000-000000000012"), new Guid("00000010-0000-0000-0000-000000000002") },
                    { new Guid("00000009-0000-0000-0000-000000000012"), new Guid("00000010-0000-0000-0000-000000000003") },
                    { new Guid("00000009-0000-0000-0000-000000000012"), new Guid("00000010-0000-0000-0000-000000000004") },
                    { new Guid("00000009-0000-0000-0000-000000000012"), new Guid("00000010-0000-0000-0000-000000000005") },
                    { new Guid("00000009-0000-0000-0000-000000000012"), new Guid("00000010-0000-0000-0000-000000000007") },
                    { new Guid("00000009-0000-0000-0000-000000000012"), new Guid("00000010-0000-0000-0000-000000000008") },
                    { new Guid("00000009-0000-0000-0000-000000000012"), new Guid("00000010-0000-0000-0000-000000000009") },
                    { new Guid("00000009-0000-0000-0000-000000000012"), new Guid("00000010-0000-0000-0000-000000000012") },
                    { new Guid("00000009-0000-0000-0000-000000000012"), new Guid("00000010-0000-0000-0000-000000000013") },
                    { new Guid("00000009-0000-0000-0000-000000000012"), new Guid("00000010-0000-0000-0000-000000000014") }
                });

            migrationBuilder.Sql(@"
UPDATE a SET a.AccommodationTypeId = t.Id
FROM Accommodations a
INNER JOIN AccommodationTypes t ON t.SortOrder = a.TypeOfAccommodation
WHERE a.AccommodationTypeId = '00000000-0000-0000-0000-000000000000';

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'Bathub' AND d.[Bathub] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'Balcony' AND d.[Balcony] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'PrivateBathroom' AND d.[PrivateBathroom] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'AC' AND d.[AC] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'Terrace' AND d.[Terrace] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'Kitchen' AND d.[Kitchen] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'PrivatePool' AND d.[PrivatePool] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'CoffeeMachine' AND d.[CoffeeMachine] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'View' AND d.[View] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'SeaView' AND d.[SeaView] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'WashingMachine' AND d.[WashingMachine] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'SpaTub' AND d.[SpaTub] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'SoundProof' AND d.[SoundProof] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);

INSERT INTO AccommodationDetailsAmenities (AccommodationDetailsId, AmenityId)
SELECT d.Id, m.Id FROM AccommodationDetails d
CROSS JOIN Amenities m
WHERE m.Code = 'Breakfast' AND d.[Breakfast] = 1
  AND NOT EXISTS (SELECT 1 FROM AccommodationDetailsAmenities x
                  WHERE x.AccommodationDetailsId = d.Id AND x.AmenityId = m.Id);
");

            migrationBuilder.CreateIndex(
                name: "IX_Accommodations_AccommodationTypeId",
                table: "Accommodations",
                column: "AccommodationTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_AccommodationDetailsAmenities_AmenityId",
                table: "AccommodationDetailsAmenities",
                column: "AmenityId");

            migrationBuilder.CreateIndex(
                name: "IX_AccommodationTypes_Name",
                table: "AccommodationTypes",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Amenities_Code",
                table: "Amenities",
                column: "Code",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Accommodations_AccommodationTypes_AccommodationTypeId",
                table: "Accommodations",
                column: "AccommodationTypeId",
                principalTable: "AccommodationTypes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.DropColumn(
                name: "TypeOfAccommodation",
                table: "Accommodations");

            migrationBuilder.DropColumn(
                name: "AC",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "Balcony",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "Bathub",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "Breakfast",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "CoffeeMachine",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "Kitchen",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "PrivateBathroom",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "PrivatePool",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "SeaView",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "SoundProof",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "SpaTub",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "Terrace",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "View",
                table: "AccommodationDetails");

            migrationBuilder.DropColumn(
                name: "WashingMachine",
                table: "AccommodationDetails");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Accommodations_AccommodationTypes_AccommodationTypeId",
                table: "Accommodations");

            migrationBuilder.DropTable(
                name: "AccommodationDetailsAmenities");

            migrationBuilder.DropTable(
                name: "AccommodationTypes");

            migrationBuilder.DropTable(
                name: "Amenities");

            migrationBuilder.DropIndex(
                name: "IX_Accommodations_AccommodationTypeId",
                table: "Accommodations");

            migrationBuilder.DropColumn(
                name: "AccommodationTypeId",
                table: "Accommodations");

            migrationBuilder.AddColumn<int>(
                name: "TypeOfAccommodation",
                table: "Accommodations",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "AC",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Balcony",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Bathub",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Breakfast",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "CoffeeMachine",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Kitchen",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "PrivateBathroom",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "PrivatePool",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "SeaView",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "SoundProof",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "SpaTub",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "Terrace",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "View",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "WashingMachine",
                table: "AccommodationDetails",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000001"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { true, true, true, false, true, true, true, true, false, false, true, true, true, true });

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000002"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { true, true, false, false, true, true, true, false, false, true, false, false, true, true });

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000003"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { true, true, true, true, true, false, true, false, false, true, false, false, true, false });

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000004"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { true, false, false, false, false, true, false, false, false, false, false, false, false, true });

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000005"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { true, true, true, false, true, true, true, false, false, true, true, true, true, true });

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000006"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { false, true, false, false, false, true, true, false, false, false, false, true, true, true });

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000007"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { true, true, false, false, true, true, true, false, false, false, false, false, true, false });

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000008"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { true, true, true, false, true, true, true, true, true, false, true, true, true, true });

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000009"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { true, true, false, false, true, true, true, false, true, true, false, false, true, true });

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000010"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { true, true, true, true, true, false, true, false, true, true, true, true, true, false });

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000011"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { false, false, true, false, true, true, true, false, false, false, false, true, true, true });

            migrationBuilder.UpdateData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000012"),
                columns: new[] { "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "Kitchen", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[] { true, true, true, true, true, false, true, true, false, true, true, true, true, false });

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000001"),
                column: "TypeOfAccommodation",
                value: 5);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000002"),
                column: "TypeOfAccommodation",
                value: 4);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000003"),
                column: "TypeOfAccommodation",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000004"),
                column: "TypeOfAccommodation",
                value: 6);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000005"),
                column: "TypeOfAccommodation",
                value: 8);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000006"),
                column: "TypeOfAccommodation",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000007"),
                column: "TypeOfAccommodation",
                value: 4);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000008"),
                column: "TypeOfAccommodation",
                value: 5);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000009"),
                column: "TypeOfAccommodation",
                value: 4);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000010"),
                column: "TypeOfAccommodation",
                value: 2);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000011"),
                column: "TypeOfAccommodation",
                value: 7);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000012"),
                column: "TypeOfAccommodation",
                value: 3);
        }
    }
}
