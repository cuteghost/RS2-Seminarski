using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class accommodationUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Accommodations_AccommodationDetails_AccommodationDetailsId",
                table: "Accommodations");

            migrationBuilder.DropForeignKey(
                name: "FK_Accommodations_Locations_LocationId",
                table: "Accommodations");

            migrationBuilder.AlterColumn<Guid>(
                name: "LocationId",
                table: "Accommodations",
                type: "uniqueidentifier",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier");

            migrationBuilder.AlterColumn<Guid>(
                name: "AccommodationDetailsId",
                table: "Accommodations",
                type: "uniqueidentifier",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier");

            migrationBuilder.AddColumn<int>(
                name: "NumberOfBeds",
                table: "AccommodationDetails",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddForeignKey(
                name: "FK_Accommodations_AccommodationDetails_AccommodationDetailsId",
                table: "Accommodations",
                column: "AccommodationDetailsId",
                principalTable: "AccommodationDetails",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Accommodations_Locations_LocationId",
                table: "Accommodations",
                column: "LocationId",
                principalTable: "Locations",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Accommodations_AccommodationDetails_AccommodationDetailsId",
                table: "Accommodations");

            migrationBuilder.DropForeignKey(
                name: "FK_Accommodations_Locations_LocationId",
                table: "Accommodations");

            migrationBuilder.DropColumn(
                name: "NumberOfBeds",
                table: "AccommodationDetails");

            migrationBuilder.AlterColumn<Guid>(
                name: "LocationId",
                table: "Accommodations",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier",
                oldNullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "AccommodationDetailsId",
                table: "Accommodations",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Accommodations_AccommodationDetails_AccommodationDetailsId",
                table: "Accommodations",
                column: "AccommodationDetailsId",
                principalTable: "AccommodationDetails",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Accommodations_Locations_LocationId",
                table: "Accommodations",
                column: "LocationId",
                principalTable: "Locations",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
