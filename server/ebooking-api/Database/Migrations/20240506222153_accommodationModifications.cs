using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class accommodationModifications : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Image",
                table: "Accommodations");

            migrationBuilder.DropColumn(
                name: "ImageThumb",
                table: "Accommodations");

            migrationBuilder.AddColumn<Guid>(
                name: "AccommodationImagesId",
                table: "Accommodations",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.CreateTable(
                name: "AccommodationImages",
                columns: table => new
                {
                    AccommodationImagesId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Image1 = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    Image2 = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    Image3 = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    Image4 = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    Image5 = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    Image6 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image7 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image8 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image9 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image10 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image12 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image13 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image14 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image15 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image16 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image17 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image18 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image19 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    Image20 = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AccommodationImages", x => x.AccommodationImagesId);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Accommodations_AccommodationImagesId",
                table: "Accommodations",
                column: "AccommodationImagesId");

            migrationBuilder.AddForeignKey(
                name: "FK_Accommodations_AccommodationImages_AccommodationImagesId",
                table: "Accommodations",
                column: "AccommodationImagesId",
                principalTable: "AccommodationImages",
                principalColumn: "AccommodationImagesId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Accommodations_AccommodationImages_AccommodationImagesId",
                table: "Accommodations");

            migrationBuilder.DropTable(
                name: "AccommodationImages");

            migrationBuilder.DropIndex(
                name: "IX_Accommodations_AccommodationImagesId",
                table: "Accommodations");

            migrationBuilder.DropColumn(
                name: "AccommodationImagesId",
                table: "Accommodations");

            migrationBuilder.AddColumn<byte[]>(
                name: "Image",
                table: "Accommodations",
                type: "varbinary(max)",
                nullable: true);

            migrationBuilder.AddColumn<byte[]>(
                name: "ImageThumb",
                table: "Accommodations",
                type: "varbinary(max)",
                nullable: false,
                defaultValue: new byte[0]);
        }
    }
}
