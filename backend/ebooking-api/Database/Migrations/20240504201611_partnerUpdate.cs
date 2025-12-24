using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class partnerUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Partners_Locations_LocationId",
                table: "Partners");

            migrationBuilder.DropIndex(
                name: "IX_Partners_LocationId",
                table: "Partners");

            migrationBuilder.DropColumn(
                name: "LocationId",
                table: "Partners");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "LocationId",
                table: "Partners",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Partners_LocationId",
                table: "Partners",
                column: "LocationId");

            migrationBuilder.AddForeignKey(
                name: "FK_Partners_Locations_LocationId",
                table: "Partners",
                column: "LocationId",
                principalTable: "Locations",
                principalColumn: "Id");
        }
    }
}
