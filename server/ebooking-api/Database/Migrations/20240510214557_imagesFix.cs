using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class imagesFix : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Accommodations_AccommodationImages_AccommodationImagesId",
                table: "Accommodations");

            migrationBuilder.AlterColumn<Guid>(
                name: "AccommodationImagesId",
                table: "Accommodations",
                type: "uniqueidentifier",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier");

            migrationBuilder.AddColumn<byte[]>(
                name: "Image11",
                table: "AccommodationImages",
                type: "varbinary(max)",
                nullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Accommodations_AccommodationImages_AccommodationImagesId",
                table: "Accommodations",
                column: "AccommodationImagesId",
                principalTable: "AccommodationImages",
                principalColumn: "AccommodationImagesId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Accommodations_AccommodationImages_AccommodationImagesId",
                table: "Accommodations");

            migrationBuilder.DropColumn(
                name: "Image11",
                table: "AccommodationImages");

            migrationBuilder.AlterColumn<Guid>(
                name: "AccommodationImagesId",
                table: "Accommodations",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Accommodations_AccommodationImages_AccommodationImagesId",
                table: "Accommodations",
                column: "AccommodationImagesId",
                principalTable: "AccommodationImages",
                principalColumn: "AccommodationImagesId",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
