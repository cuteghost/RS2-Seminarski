using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class FilterUniqueIndexesOnSoftDelete : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Countries_Name",
                table: "Countries");

            migrationBuilder.DropIndex(
                name: "IX_Amenities_Code",
                table: "Amenities");

            migrationBuilder.DropIndex(
                name: "IX_AccommodationTypes_Name",
                table: "AccommodationTypes");

            migrationBuilder.CreateIndex(
                name: "IX_Countries_Name",
                table: "Countries",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_Amenities_Code",
                table: "Amenities",
                column: "Code",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_AccommodationTypes_Name",
                table: "AccommodationTypes",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Countries_Name",
                table: "Countries");

            migrationBuilder.DropIndex(
                name: "IX_Amenities_Code",
                table: "Amenities");

            migrationBuilder.DropIndex(
                name: "IX_AccommodationTypes_Name",
                table: "AccommodationTypes");

            migrationBuilder.CreateIndex(
                name: "IX_Countries_Name",
                table: "Countries",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Amenities_Code",
                table: "Amenities",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AccommodationTypes_Name",
                table: "AccommodationTypes",
                column: "Name",
                unique: true);
        }
    }
}
