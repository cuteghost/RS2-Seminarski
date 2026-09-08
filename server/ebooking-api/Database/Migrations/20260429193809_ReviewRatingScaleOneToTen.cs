using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class ReviewRatingScaleOneToTen : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000001"),
                column: "ReviewScore",
                value: 1.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000002"),
                column: "ReviewScore",
                value: 2.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000003"),
                column: "ReviewScore",
                value: 3.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000004"),
                column: "ReviewScore",
                value: 4.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000005"),
                column: "ReviewScore",
                value: 5.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000006"),
                column: "ReviewScore",
                value: 6.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000007"),
                column: "ReviewScore",
                value: 7.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000008"),
                column: "ReviewScore",
                value: 8.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000009"),
                column: "ReviewScore",
                value: 9.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000010"),
                column: "ReviewScore",
                value: 5.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000011"),
                column: "ReviewScore",
                value: 1.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000012"),
                column: "ReviewScore",
                value: 2.5m);

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000001"),
                column: "Rating",
                value: 1);

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000002"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 2, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000003"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 2, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000004"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 3, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000005"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 3, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000006"),
                columns: new[] { "Comment", "Rating" },
                values: new object[] { "", 4 });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000007"),
                columns: new[] { "Comment", "Rating" },
                values: new object[] { "", 4 });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000008"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 5, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000009"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 5, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000010"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 6, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000011"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 6, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000012"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 7, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000013"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 7, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000014"),
                columns: new[] { "Comment", "Rating" },
                values: new object[] { "", 8 });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000015"),
                columns: new[] { "Comment", "Rating" },
                values: new object[] { "", 8 });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000016"),
                column: "Rating",
                value: 9);

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000017"),
                column: "Rating",
                value: 9);

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000018"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 10, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000019"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 10, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000020"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 1, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000021"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 1, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000022"),
                columns: new[] { "Comment", "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { "", 2, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000023"),
                columns: new[] { "Comment", "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { "", 2, false, false });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000001"),
                column: "ReviewScore",
                value: 3.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000002"),
                column: "ReviewScore",
                value: 4.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000003"),
                column: "ReviewScore",
                value: 4m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000004"),
                column: "ReviewScore",
                value: 3.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000005"),
                column: "ReviewScore",
                value: 4.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000006"),
                column: "ReviewScore",
                value: 4m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000007"),
                column: "ReviewScore",
                value: 3.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000008"),
                column: "ReviewScore",
                value: 4.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000009"),
                column: "ReviewScore",
                value: 4m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000010"),
                column: "ReviewScore",
                value: 3.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000011"),
                column: "ReviewScore",
                value: 4.5m);

            migrationBuilder.UpdateData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000012"),
                column: "ReviewScore",
                value: 4m);

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000001"),
                column: "Rating",
                value: 3);

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000002"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 4, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000003"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 4, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000004"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 5, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000005"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 5, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000006"),
                columns: new[] { "Comment", "Rating" },
                values: new object[] { "Sve je bilo uredno, ali grijanje je slabo radilo prve večeri dok domaćin nije došao i podesio ga.", 3 });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000007"),
                columns: new[] { "Comment", "Rating" },
                values: new object[] { "Sve je bilo uredno, ali grijanje je slabo radilo prve večeri dok domaćin nije došao i podesio ga.", 3 });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000008"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 4, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000009"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 4, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000010"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 5, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000011"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 5, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000012"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 3, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000013"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 3, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000014"),
                columns: new[] { "Comment", "Rating" },
                values: new object[] { "Čisto, tiho i blizu centra. Jedina zamjerka je parking koji se popuni rano popodne.", 4 });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000015"),
                columns: new[] { "Comment", "Rating" },
                values: new object[] { "Čisto, tiho i blizu centra. Jedina zamjerka je parking koji se popuni rano popodne.", 4 });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000016"),
                column: "Rating",
                value: 5);

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000017"),
                column: "Rating",
                value: 5);

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000018"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 3, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000019"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 3, false, false });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000020"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 4, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000021"),
                columns: new[] { "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { 4, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000022"),
                columns: new[] { "Comment", "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { "Kupatilo bi trebalo osvježiti, sve ostalo je bilo besprijekorno i dobili smo kasniji odjavni termin.", 5, true, true });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000023"),
                columns: new[] { "Comment", "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[] { "Kupatilo bi trebalo osvježiti, sve ostalo je bilo besprijekorno i dobili smo kasniji odjavni termin.", 5, true, true });
        }
    }
}
