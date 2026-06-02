using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class RehashSeedPasswords : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000001"),
                column: "Password",
                value: "pbkdf2-sha256$210000$F4sKc/vBcNAHlTczfUeA3g==$LUTXGVXtMq8Uur6S3ASNUONf7T+432LDByBNv1dMKsE=");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000002"),
                column: "Password",
                value: "pbkdf2-sha256$210000$UhC9GXZqavEsAGJn9zbRwQ==$Rz2+XiH0Ui9683w0xuUefPSLOzrk5gGbm+4vOwdHykk=");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000003"),
                column: "Password",
                value: "pbkdf2-sha256$210000$XdfzQkcLsN4YQlSCpg/gcg==$WPuYCvaok41trGvT2ncbpeakLOUnHdW9JJfuJbEUnug=");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000004"),
                column: "Password",
                value: "pbkdf2-sha256$210000$5IljL8kifIRsrp9674xXzA==$XMI04NeoIRRkOurPvdwsX3097utpIs65NgCcP0UKGmo=");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000005"),
                column: "Password",
                value: "pbkdf2-sha256$210000$sUfGRW2b3aYL9DiDBgsznw==$G5PH9AH2Tr6j4UeZKvbdK7t19AniWgjnpOT0qikPb8Q=");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000006"),
                column: "Password",
                value: "pbkdf2-sha256$210000$q+yfAiHLdAve+zlMAQ+9iQ==$iL61ES5hCKjQ3+qktR15LXekmOtHQGi/ioQf9PmnwmM=");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000007"),
                column: "Password",
                value: "pbkdf2-sha256$210000$lFIW5xtQMv5VWfNw1rVLLw==$2tU7BEZVNV0mynJBhoy7fCd4TtcyOmAHzeHJbqW7N54=");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000008"),
                column: "Password",
                value: "pbkdf2-sha256$210000$BCJh96cpPJYZL96P4l4dmQ==$P8f57xgxkL9QiVulZ6Ve//gVw2elhzijjrsyV4+qpKk=");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000009"),
                column: "Password",
                value: "pbkdf2-sha256$210000$71wU3gNAAjy7UFRJpDT/hQ==$6VdEE7A/qJpvX3NpYeIkzvHmRbfVB69QOKUiwsy/luU=");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000001"),
                column: "Password",
                value: "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000002"),
                column: "Password",
                value: "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000003"),
                column: "Password",
                value: "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000004"),
                column: "Password",
                value: "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000005"),
                column: "Password",
                value: "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000006"),
                column: "Password",
                value: "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000007"),
                column: "Password",
                value: "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000008"),
                column: "Password",
                value: "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000009"),
                column: "Password",
                value: "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7");
        }
    }
}
