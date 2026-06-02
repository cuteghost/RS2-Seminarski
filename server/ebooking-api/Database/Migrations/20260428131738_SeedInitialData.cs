using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Database.Migrations
{
    /// <inheritdoc />
    public partial class SeedInitialData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "AccommodationDetails",
                columns: new[] { "Id", "AC", "Balcony", "Bathub", "Breakfast", "CoffeeMachine", "IsDeleted", "Kitchen", "NumberOfBeds", "PrivateBathroom", "PrivatePool", "SeaView", "SoundProof", "SpaTub", "Terrace", "View", "WashingMachine" },
                values: new object[,]
                {
                    { new Guid("00000009-0000-0000-0000-000000000001"), true, true, true, false, true, false, true, 8, true, true, false, false, true, true, true, true },
                    { new Guid("00000009-0000-0000-0000-000000000002"), true, true, false, false, true, false, true, 4, true, false, false, true, false, false, true, true },
                    { new Guid("00000009-0000-0000-0000-000000000003"), true, true, true, true, true, false, false, 2, true, false, false, true, false, false, true, false },
                    { new Guid("00000009-0000-0000-0000-000000000004"), true, false, false, false, false, false, true, 6, false, false, false, false, false, false, false, true },
                    { new Guid("00000009-0000-0000-0000-000000000005"), true, true, true, false, true, false, true, 5, true, false, false, true, true, true, true, true },
                    { new Guid("00000009-0000-0000-0000-000000000006"), false, true, false, false, false, false, true, 7, true, false, false, false, false, true, true, true },
                    { new Guid("00000009-0000-0000-0000-000000000007"), true, true, false, false, true, false, true, 4, true, false, false, false, false, false, true, false },
                    { new Guid("00000009-0000-0000-0000-000000000008"), true, true, true, false, true, false, true, 9, true, true, true, false, true, true, true, true },
                    { new Guid("00000009-0000-0000-0000-000000000009"), true, true, false, false, true, false, true, 4, true, false, true, true, false, false, true, true },
                    { new Guid("00000009-0000-0000-0000-000000000010"), true, true, true, true, true, false, false, 2, true, false, true, true, true, true, true, false },
                    { new Guid("00000009-0000-0000-0000-000000000011"), false, false, true, false, true, false, true, 6, true, false, false, false, false, true, true, true },
                    { new Guid("00000009-0000-0000-0000-000000000012"), true, true, true, true, true, false, false, 3, true, true, false, true, true, true, true, false }
                });

            migrationBuilder.InsertData(
                table: "AccommodationImages",
                columns: new[] { "AccommodationImagesId", "Image1", "Image10", "Image11", "Image12", "Image13", "Image14", "Image15", "Image16", "Image17", "Image18", "Image19", "Image2", "Image20", "Image3", "Image4", "Image5", "Image6", "Image7", "Image8", "Image9", "IsDeleted" },
                values: new object[,]
                {
                    { new Guid("0000000a-0000-0000-0000-000000000001"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false },
                    { new Guid("0000000a-0000-0000-0000-000000000002"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false },
                    { new Guid("0000000a-0000-0000-0000-000000000003"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false },
                    { new Guid("0000000a-0000-0000-0000-000000000004"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false },
                    { new Guid("0000000a-0000-0000-0000-000000000005"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false },
                    { new Guid("0000000a-0000-0000-0000-000000000006"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false },
                    { new Guid("0000000a-0000-0000-0000-000000000007"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false },
                    { new Guid("0000000a-0000-0000-0000-000000000008"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false },
                    { new Guid("0000000a-0000-0000-0000-000000000009"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false },
                    { new Guid("0000000a-0000-0000-0000-000000000010"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false },
                    { new Guid("0000000a-0000-0000-0000-000000000011"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false },
                    { new Guid("0000000a-0000-0000-0000-000000000012"), new byte[0], null, null, null, null, null, null, null, null, null, null, new byte[0], null, new byte[0], new byte[0], new byte[0], null, null, null, null, false }
                });

            migrationBuilder.InsertData(
                table: "Countries",
                columns: new[] { "Id", "IsDeleted", "Name" },
                values: new object[,]
                {
                    { new Guid("00000001-0000-0000-0000-000000000001"), false, "Bosna i Hercegovina" },
                    { new Guid("00000001-0000-0000-0000-000000000002"), false, "Hrvatska" },
                    { new Guid("00000001-0000-0000-0000-000000000003"), false, "Srbija" },
                    { new Guid("00000001-0000-0000-0000-000000000004"), false, "Crna Gora" },
                    { new Guid("00000001-0000-0000-0000-000000000005"), false, "Slovenija" },
                    { new Guid("00000001-0000-0000-0000-000000000006"), false, "Austrija" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "BirthDate", "DisplayName", "Email", "FirstName", "Gender", "Image", "IsActive", "IsDeleted", "Joined", "LastName", "Password", "Role", "SocialLink" },
                values: new object[,]
                {
                    { new Guid("00000004-0000-0000-0000-000000000001"), new DateTime(1988, 3, 14, 0, 0, 0, 0, DateTimeKind.Unspecified), "Amir Hodžić", "admin@ebooking.com", "Amir", (short)0, null, true, false, new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "Hodžić", "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7", 1337, "" },
                    { new Guid("00000004-0000-0000-0000-000000000002"), new DateTime(1990, 7, 22, 0, 0, 0, 0, DateTimeKind.Unspecified), "Dino Kovačević", "dude@email.com", "Dino", (short)0, null, true, false, new DateTime(2024, 2, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), "Kovačević", "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7", 1, "" },
                    { new Guid("00000004-0000-0000-0000-000000000003"), new DateTime(1986, 11, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), "Ivana Marić", "adriatic@email.com", "Ivana", (short)1, null, true, false, new DateTime(2024, 2, 18, 0, 0, 0, 0, DateTimeKind.Unspecified), "Marić", "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7", 1, "" },
                    { new Guid("00000004-0000-0000-0000-000000000004"), new DateTime(1983, 5, 27, 0, 0, 0, 0, DateTimeKind.Unspecified), "Marko Novak", "alpine@email.com", "Marko", (short)0, null, true, false, new DateTime(2024, 3, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), "Novak", "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7", 1, "" },
                    { new Guid("00000004-0000-0000-0000-000000000005"), new DateTime(1994, 4, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), "Dea Selimović", "dea@email.com", "Dea", (short)1, null, true, false, new DateTime(2024, 3, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "Selimović", "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7", 0, "" },
                    { new Guid("00000004-0000-0000-0000-000000000006"), new DateTime(1997, 9, 19, 0, 0, 0, 0, DateTimeKind.Unspecified), "Amina Softić", "mobile@ebooking.com", "Amina", (short)1, null, true, false, new DateTime(2024, 4, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Softić", "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7", 0, "" },
                    { new Guid("00000004-0000-0000-0000-000000000007"), new DateTime(1992, 12, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), "Lejla Bešić", "lejla@email.com", "Lejla", (short)1, null, true, false, new DateTime(2024, 4, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "Bešić", "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7", 0, "" },
                    { new Guid("00000004-0000-0000-0000-000000000008"), new DateTime(1989, 6, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), "Emir Delić", "emir@email.com", "Emir", (short)0, null, true, false, new DateTime(2024, 5, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), "Delić", "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7", 0, "" },
                    { new Guid("00000004-0000-0000-0000-000000000009"), new DateTime(1995, 1, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Tarik Zulfikarpašić", "tarik@email.com", "Tarik", (short)0, null, true, false, new DateTime(2024, 5, 23, 0, 0, 0, 0, DateTimeKind.Unspecified), "Zulfikarpašić", "e3bcb85cc3094a428058a741949eed1b13f3070201b8b0cbb0d81f28006307a7", 0, "" }
                });

            migrationBuilder.InsertData(
                table: "Administrators",
                columns: new[] { "Id", "CreatorId", "IsDeleted", "Joined", "UserId" },
                values: new object[] { new Guid("00000005-0000-0000-0000-000000000001"), null, false, new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), new Guid("00000004-0000-0000-0000-000000000001") });

            migrationBuilder.InsertData(
                table: "Chats",
                columns: new[] { "Id", "User1Id", "User2Id" },
                values: new object[,]
                {
                    { new Guid("0000000d-0000-0000-0000-000000000001"), new Guid("00000004-0000-0000-0000-000000000005"), new Guid("00000004-0000-0000-0000-000000000002") },
                    { new Guid("0000000d-0000-0000-0000-000000000002"), new Guid("00000004-0000-0000-0000-000000000007"), new Guid("00000004-0000-0000-0000-000000000003") }
                });

            migrationBuilder.InsertData(
                table: "Cities",
                columns: new[] { "Id", "CountryId", "IsDeleted", "Name" },
                values: new object[,]
                {
                    { new Guid("00000002-0000-0000-0000-000000000001"), new Guid("00000001-0000-0000-0000-000000000001"), false, "Sarajevo" },
                    { new Guid("00000002-0000-0000-0000-000000000002"), new Guid("00000001-0000-0000-0000-000000000001"), false, "Mostar" },
                    { new Guid("00000002-0000-0000-0000-000000000003"), new Guid("00000001-0000-0000-0000-000000000001"), false, "Banja Luka" },
                    { new Guid("00000002-0000-0000-0000-000000000004"), new Guid("00000001-0000-0000-0000-000000000002"), false, "Zagreb" },
                    { new Guid("00000002-0000-0000-0000-000000000005"), new Guid("00000001-0000-0000-0000-000000000002"), false, "Split" },
                    { new Guid("00000002-0000-0000-0000-000000000006"), new Guid("00000001-0000-0000-0000-000000000002"), false, "Dubrovnik" },
                    { new Guid("00000002-0000-0000-0000-000000000007"), new Guid("00000001-0000-0000-0000-000000000003"), false, "Beograd" },
                    { new Guid("00000002-0000-0000-0000-000000000008"), new Guid("00000001-0000-0000-0000-000000000004"), false, "Budva" },
                    { new Guid("00000002-0000-0000-0000-000000000009"), new Guid("00000001-0000-0000-0000-000000000005"), false, "Ljubljana" },
                    { new Guid("00000002-0000-0000-0000-000000000010"), new Guid("00000001-0000-0000-0000-000000000006"), false, "Salzburg" }
                });

            migrationBuilder.InsertData(
                table: "Customers",
                columns: new[] { "Id", "IsDeleted", "UserId" },
                values: new object[,]
                {
                    { new Guid("00000007-0000-0000-0000-000000000001"), false, new Guid("00000004-0000-0000-0000-000000000005") },
                    { new Guid("00000007-0000-0000-0000-000000000002"), false, new Guid("00000004-0000-0000-0000-000000000006") },
                    { new Guid("00000007-0000-0000-0000-000000000003"), false, new Guid("00000004-0000-0000-0000-000000000007") },
                    { new Guid("00000007-0000-0000-0000-000000000004"), false, new Guid("00000004-0000-0000-0000-000000000008") },
                    { new Guid("00000007-0000-0000-0000-000000000005"), false, new Guid("00000004-0000-0000-0000-000000000009") }
                });

            migrationBuilder.InsertData(
                table: "Partners",
                columns: new[] { "Id", "CountryId", "IsDeleted", "PhoneNumber", "TaxId", "TaxName", "UserId" },
                values: new object[,]
                {
                    { new Guid("00000006-0000-0000-0000-000000000001"), new Guid("00000001-0000-0000-0000-000000000001"), false, 38761234567L, 4200123450006L, "Dude Apartments d.o.o.", new Guid("00000004-0000-0000-0000-000000000002") },
                    { new Guid("00000006-0000-0000-0000-000000000002"), new Guid("00000001-0000-0000-0000-000000000002"), false, 385912345678L, 7700998811223L, "Adriatic Stays j.d.o.o.", new Guid("00000004-0000-0000-0000-000000000003") },
                    { new Guid("00000006-0000-0000-0000-000000000003"), new Guid("00000001-0000-0000-0000-000000000005"), false, 38641234567L, 5500221144667L, "Alpine Rooms d.o.o.", new Guid("00000004-0000-0000-0000-000000000004") }
                });

            migrationBuilder.InsertData(
                table: "Locations",
                columns: new[] { "Id", "Address", "CityId", "IsDeleted", "Latitude", "Longitude" },
                values: new object[,]
                {
                    { new Guid("00000003-0000-0000-0000-000000000001"), "Poljine 14", new Guid("00000002-0000-0000-0000-000000000001"), false, 43.890099999999997, 18.410299999999999 },
                    { new Guid("00000003-0000-0000-0000-000000000002"), "Bravadžiluk 24", new Guid("00000002-0000-0000-0000-000000000001"), false, 43.859400000000001, 18.431799999999999 },
                    { new Guid("00000003-0000-0000-0000-000000000003"), "Obala Kulina bana 8", new Guid("00000002-0000-0000-0000-000000000001"), false, 43.858899999999998, 18.434000000000001 },
                    { new Guid("00000003-0000-0000-0000-000000000004"), "Obala Isa-bega Ishakovića 5", new Guid("00000002-0000-0000-0000-000000000001"), false, 43.857799999999997, 18.4283 },
                    { new Guid("00000003-0000-0000-0000-000000000005"), "Zmaja od Bosne 4", new Guid("00000002-0000-0000-0000-000000000001"), false, 43.856299999999997, 18.403300000000002 },
                    { new Guid("00000003-0000-0000-0000-000000000006"), "Trebevićka 88", new Guid("00000002-0000-0000-0000-000000000001"), false, 43.841999999999999, 18.428999999999998 },
                    { new Guid("00000003-0000-0000-0000-000000000007"), "Maršala Tita 179", new Guid("00000002-0000-0000-0000-000000000002"), false, 43.337200000000003, 17.815000000000001 },
                    { new Guid("00000003-0000-0000-0000-000000000008"), "Šetalište Bačvice 10", new Guid("00000002-0000-0000-0000-000000000005"), false, 43.503, 16.452999999999999 },
                    { new Guid("00000003-0000-0000-0000-000000000009"), "Poljana Grgura Ninskog 3", new Guid("00000002-0000-0000-0000-000000000005"), false, 43.508099999999999, 16.440200000000001 },
                    { new Guid("00000003-0000-0000-0000-000000000010"), "Masarykov put 9", new Guid("00000002-0000-0000-0000-000000000006"), false, 42.645000000000003, 18.085000000000001 },
                    { new Guid("00000003-0000-0000-0000-000000000011"), "Cesta na Rožnik 7", new Guid("00000002-0000-0000-0000-000000000009"), false, 46.054000000000002, 14.472 },
                    { new Guid("00000003-0000-0000-0000-000000000012"), "Hellbrunner Allee 20", new Guid("00000002-0000-0000-0000-000000000010"), false, 47.780000000000001, 13.050000000000001 }
                });

            migrationBuilder.InsertData(
                table: "Messages",
                columns: new[] { "Id", "ChatId", "Content", "IsRead", "SenderId", "Timestamp" },
                values: new object[,]
                {
                    { new Guid("0000000e-0000-0000-0000-000000000001"), new Guid("0000000d-0000-0000-0000-000000000001"), "Dobar dan, da li je Apartman Baščaršija slobodan u prvoj sedmici juna?", true, new Guid("00000004-0000-0000-0000-000000000005"), new DateTime(2026, 5, 12, 9, 14, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000e-0000-0000-0000-000000000002"), new Guid("0000000d-0000-0000-0000-000000000001"), "Dobar dan, jeste. Prijava je od 14 sati, odjava do 11.", true, new Guid("00000004-0000-0000-0000-000000000002"), new DateTime(2026, 5, 12, 9, 31, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000e-0000-0000-0000-000000000003"), new Guid("0000000d-0000-0000-0000-000000000001"), "Odlično, da li je parking uključen u cijenu?", true, new Guid("00000004-0000-0000-0000-000000000005"), new DateTime(2026, 5, 12, 9, 35, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000e-0000-0000-0000-000000000004"), new Guid("0000000d-0000-0000-0000-000000000001"), "Jeste, jedno mjesto u dvorištu zgrade. Rezervaciju možete potvrditi kroz aplikaciju.", false, new Guid("00000004-0000-0000-0000-000000000002"), new DateTime(2026, 5, 12, 9, 40, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000e-0000-0000-0000-000000000005"), new Guid("0000000d-0000-0000-0000-000000000002"), "Zanima me Villa Riva za produženi vikend u julu, koliko osoba prima?", true, new Guid("00000004-0000-0000-0000-000000000007"), new DateTime(2026, 6, 3, 18, 2, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000e-0000-0000-0000-000000000006"), new Guid("0000000d-0000-0000-0000-000000000002"), "Vila prima do devet osoba, ima privatni bazen i izlaz na šetnicu.", true, new Guid("00000004-0000-0000-0000-000000000003"), new DateTime(2026, 6, 3, 18, 20, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000e-0000-0000-0000-000000000007"), new Guid("0000000d-0000-0000-0000-000000000002"), "Ima li mogućnost kasnije prijave, stižemo oko 22 sata?", true, new Guid("00000004-0000-0000-0000-000000000007"), new DateTime(2026, 6, 3, 18, 24, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000e-0000-0000-0000-000000000008"), new Guid("0000000d-0000-0000-0000-000000000002"), "Nema problema, sačekat ću vas na licu mjesta.", false, new Guid("00000004-0000-0000-0000-000000000003"), new DateTime(2026, 6, 3, 18, 29, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Accommodations",
                columns: new[] { "Id", "AccommodationDetailsId", "AccommodationImagesId", "Description", "IsDeleted", "LocationId", "Name", "OwnerId", "PricePerNight", "ReviewScore", "Status", "TypeOfAccommodation" },
                values: new object[,]
                {
                    { new Guid("00000008-0000-0000-0000-000000000001"), new Guid("00000009-0000-0000-0000-000000000001"), new Guid("0000000a-0000-0000-0000-000000000001"), "Vila sa pet spavaćih soba i pogledom na sarajevsku kotlinu, deset minuta vožnje od centra grada.", false, new Guid("00000003-0000-0000-0000-000000000001"), "Villa Poljine", new Guid("00000006-0000-0000-0000-000000000001"), 180.0, 3.5m, true, 5 },
                    { new Guid("00000008-0000-0000-0000-000000000002"), new Guid("00000009-0000-0000-0000-000000000002"), new Guid("0000000a-0000-0000-0000-000000000002"), "Apartman u srcu Baščaršije, uz Sebilj i glavnu pješačku zonu, sa potpuno opremljenom kuhinjom.", false, new Guid("00000003-0000-0000-0000-000000000002"), "Apartman Baščaršija", new Guid("00000006-0000-0000-0000-000000000001"), 65.0, 4.5m, true, 4 },
                    { new Guid("00000008-0000-0000-0000-000000000003"), new Guid("00000009-0000-0000-0000-000000000003"), new Guid("0000000a-0000-0000-0000-000000000003"), "Hotel na obali Miljacke, preko puta Vijećnice, sa doručkom i besplatnim parkingom za goste.", false, new Guid("00000003-0000-0000-0000-000000000003"), "Hotel Vijećnica", new Guid("00000006-0000-0000-0000-000000000001"), 120.0, 4m, true, 2 },
                    { new Guid("00000008-0000-0000-0000-000000000004"), new Guid("00000009-0000-0000-0000-000000000004"), new Guid("0000000a-0000-0000-0000-000000000004"), "Hostel uz Latinsku ćupriju sa zajedničkom kuhinjom i sobama za dva do šest gostiju.", false, new Guid("00000003-0000-0000-0000-000000000004"), "Hostel Latinska Ćuprija", new Guid("00000006-0000-0000-0000-000000000001"), 25.0, 3.5m, true, 6 },
                    { new Guid("00000008-0000-0000-0000-000000000005"), new Guid("00000009-0000-0000-0000-000000000005"), new Guid("0000000a-0000-0000-0000-000000000005"), "Potkrovni stan na Marijin Dvoru sa velikom terasom, pogledom na Trebević i dva parking mjesta.", false, new Guid("00000003-0000-0000-0000-000000000005"), "Penthouse Marijin Dvor", new Guid("00000006-0000-0000-0000-000000000001"), 210.0, 4.5m, true, 8 },
                    { new Guid("00000008-0000-0000-0000-000000000006"), new Guid("00000009-0000-0000-0000-000000000006"), new Guid("0000000a-0000-0000-0000-000000000006"), "Kuća na padinama Trebevića sa baštom i roštiljem, idealna za porodični boravak van gradske vreve.", false, new Guid("00000003-0000-0000-0000-000000000006"), "Kuća na Trebeviću", new Guid("00000006-0000-0000-0000-000000000001"), 95.0, 4m, true, 1 },
                    { new Guid("00000008-0000-0000-0000-000000000007"), new Guid("00000009-0000-0000-0000-000000000007"), new Guid("0000000a-0000-0000-0000-000000000007"), "Apartman u starom dijelu Mostara, nekoliko koraka od Starog mosta i mostarske čaršije.", false, new Guid("00000003-0000-0000-0000-000000000007"), "Apartman Stari Most", new Guid("00000006-0000-0000-0000-000000000001"), 70.0, 3.5m, true, 4 },
                    { new Guid("00000008-0000-0000-0000-000000000008"), new Guid("00000009-0000-0000-0000-000000000008"), new Guid("0000000a-0000-0000-0000-000000000008"), "Vila sa privatnim bazenom na Bačvicama, sa direktnim izlazom na šetnicu i gradsku plažu.", false, new Guid("00000003-0000-0000-0000-000000000008"), "Villa Riva", new Guid("00000006-0000-0000-0000-000000000002"), 240.0, 4.5m, true, 5 },
                    { new Guid("00000008-0000-0000-0000-000000000009"), new Guid("00000009-0000-0000-0000-000000000009"), new Guid("0000000a-0000-0000-0000-000000000009"), "Apartman unutar zidina Dioklecijanove palače, sa klimom i pogledom na staru gradsku jezgru.", false, new Guid("00000003-0000-0000-0000-000000000009"), "Apartman Dioklecijan", new Guid("00000006-0000-0000-0000-000000000002"), 110.0, 4m, true, 4 },
                    { new Guid("00000008-0000-0000-0000-000000000010"), new Guid("00000009-0000-0000-0000-000000000010"), new Guid("0000000a-0000-0000-0000-000000000010"), "Hotel iznad dubrovačkih gradskih zidina, sa spa centrom, restoranom i pogledom na otvoreno more.", false, new Guid("00000003-0000-0000-0000-000000000010"), "Hotel Adriatic", new Guid("00000006-0000-0000-0000-000000000002"), 320.0, 3.5m, true, 2 },
                    { new Guid("00000008-0000-0000-0000-000000000011"), new Guid("00000009-0000-0000-0000-000000000011"), new Guid("0000000a-0000-0000-0000-000000000011"), "Vikendica u zelenilu Rožnika, dvadeset minuta hoda od centra Ljubljane, sa kaminom i terasom.", false, new Guid("00000003-0000-0000-0000-000000000011"), "Vikendica Rožnik", new Guid("00000006-0000-0000-0000-000000000003"), 140.0, 4.5m, true, 7 },
                    { new Guid("00000008-0000-0000-0000-000000000012"), new Guid("00000009-0000-0000-0000-000000000012"), new Guid("0000000a-0000-0000-0000-000000000012"), "Resort nadomak Salzburga sa unutrašnjim bazenom, wellness centrom i pogledom na Alpe.", false, new Guid("00000003-0000-0000-0000-000000000012"), "Resort Alpenblick", new Guid("00000006-0000-0000-0000-000000000003"), 260.0, 4m, true, 3 }
                });

            migrationBuilder.InsertData(
                table: "Reservations",
                columns: new[] { "Id", "AccommodationId", "CustomerId", "EndDate", "IsDeleted", "IsRated", "NumberOfGuests", "StartDate" },
                values: new object[,]
                {
                    { new Guid("0000000b-0000-0000-0000-000000000001"), new Guid("00000008-0000-0000-0000-000000000001"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 1, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 1, new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000002"), new Guid("00000008-0000-0000-0000-000000000001"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 3, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 2, new DateTime(2026, 3, 8, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000003"), new Guid("00000008-0000-0000-0000-000000000001"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 5, 13, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 3, new DateTime(2026, 5, 9, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000004"), new Guid("00000008-0000-0000-0000-000000000001"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 7, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 4, new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000005"), new Guid("00000008-0000-0000-0000-000000000001"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 9, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 1, new DateTime(2026, 9, 10, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000006"), new Guid("00000008-0000-0000-0000-000000000002"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 1, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 2, new DateTime(2026, 1, 8, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000007"), new Guid("00000008-0000-0000-0000-000000000002"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 3, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 3, new DateTime(2026, 3, 11, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000008"), new Guid("00000008-0000-0000-0000-000000000002"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 5, 17, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 4, new DateTime(2026, 5, 12, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000009"), new Guid("00000008-0000-0000-0000-000000000002"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 7, 19, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 1, new DateTime(2026, 7, 13, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000010"), new Guid("00000008-0000-0000-0000-000000000002"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 9, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 2, new DateTime(2026, 9, 13, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000011"), new Guid("00000008-0000-0000-0000-000000000003"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 3, new DateTime(2026, 1, 11, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000012"), new Guid("00000008-0000-0000-0000-000000000003"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 3, 19, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 4, new DateTime(2026, 3, 14, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000013"), new Guid("00000008-0000-0000-0000-000000000003"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 1, new DateTime(2026, 5, 15, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000014"), new Guid("00000008-0000-0000-0000-000000000003"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 7, 18, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 2, new DateTime(2026, 7, 16, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000015"), new Guid("00000008-0000-0000-0000-000000000003"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 9, 19, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 3, new DateTime(2026, 9, 16, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000016"), new Guid("00000008-0000-0000-0000-000000000004"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 1, 19, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 4, new DateTime(2026, 1, 14, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000017"), new Guid("00000008-0000-0000-0000-000000000004"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 3, 23, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 1, new DateTime(2026, 3, 17, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000018"), new Guid("00000008-0000-0000-0000-000000000004"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 5, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 2, new DateTime(2026, 5, 18, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000019"), new Guid("00000008-0000-0000-0000-000000000004"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 7, 22, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 3, new DateTime(2026, 7, 19, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000020"), new Guid("00000008-0000-0000-0000-000000000004"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 9, 23, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 4, new DateTime(2026, 9, 19, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000021"), new Guid("00000008-0000-0000-0000-000000000005"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 1, 23, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 1, new DateTime(2026, 1, 17, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000022"), new Guid("00000008-0000-0000-0000-000000000005"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 3, 22, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 2, new DateTime(2026, 3, 20, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000023"), new Guid("00000008-0000-0000-0000-000000000005"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 5, 24, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 3, new DateTime(2026, 5, 21, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000024"), new Guid("00000008-0000-0000-0000-000000000005"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 7, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 4, new DateTime(2026, 7, 22, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000025"), new Guid("00000008-0000-0000-0000-000000000005"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 9, 27, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 1, new DateTime(2026, 9, 22, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000026"), new Guid("00000008-0000-0000-0000-000000000006"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 1, 22, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 2, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000027"), new Guid("00000008-0000-0000-0000-000000000006"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 3, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 3, new DateTime(2026, 3, 23, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000028"), new Guid("00000008-0000-0000-0000-000000000006"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 5, 28, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 4, new DateTime(2026, 5, 24, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000029"), new Guid("00000008-0000-0000-0000-000000000006"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 7, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 1, new DateTime(2026, 7, 25, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000030"), new Guid("00000008-0000-0000-0000-000000000006"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 10, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 2, new DateTime(2026, 9, 25, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000031"), new Guid("00000008-0000-0000-0000-000000000007"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 1, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 3, new DateTime(2026, 1, 23, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000032"), new Guid("00000008-0000-0000-0000-000000000007"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 3, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 4, new DateTime(2026, 3, 26, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000033"), new Guid("00000008-0000-0000-0000-000000000007"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 1, new DateTime(2026, 5, 27, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000034"), new Guid("00000008-0000-0000-0000-000000000007"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 8, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 2, new DateTime(2026, 7, 28, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000035"), new Guid("00000008-0000-0000-0000-000000000007"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 9, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 3, new DateTime(2026, 9, 28, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000036"), new Guid("00000008-0000-0000-0000-000000000008"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 1, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 4, new DateTime(2026, 1, 26, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000037"), new Guid("00000008-0000-0000-0000-000000000008"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 4, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 1, new DateTime(2026, 3, 29, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000038"), new Guid("00000008-0000-0000-0000-000000000008"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 6, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 2, new DateTime(2026, 5, 30, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000039"), new Guid("00000008-0000-0000-0000-000000000008"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 8, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 3, new DateTime(2026, 7, 31, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000040"), new Guid("00000008-0000-0000-0000-000000000008"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 10, 4, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 4, new DateTime(2026, 10, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000041"), new Guid("00000008-0000-0000-0000-000000000009"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 2, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 1, new DateTime(2026, 1, 29, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000042"), new Guid("00000008-0000-0000-0000-000000000009"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 4, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 2, new DateTime(2026, 4, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000043"), new Guid("00000008-0000-0000-0000-000000000009"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 6, 4, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 3, new DateTime(2026, 6, 2, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000044"), new Guid("00000008-0000-0000-0000-000000000009"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 8, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 4, new DateTime(2026, 8, 3, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000045"), new Guid("00000008-0000-0000-0000-000000000009"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 10, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 1, new DateTime(2026, 10, 4, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000046"), new Guid("00000008-0000-0000-0000-000000000010"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 2, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 2, new DateTime(2026, 2, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000047"), new Guid("00000008-0000-0000-0000-000000000010"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 4, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 3, new DateTime(2026, 4, 4, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000048"), new Guid("00000008-0000-0000-0000-000000000010"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 6, 8, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 4, new DateTime(2026, 6, 5, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000049"), new Guid("00000008-0000-0000-0000-000000000010"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 8, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 1, new DateTime(2026, 8, 6, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000050"), new Guid("00000008-0000-0000-0000-000000000010"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 10, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 2, new DateTime(2026, 10, 7, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000051"), new Guid("00000008-0000-0000-0000-000000000011"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 2, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 3, new DateTime(2026, 2, 4, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000052"), new Guid("00000008-0000-0000-0000-000000000011"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 4, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 4, new DateTime(2026, 4, 7, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000053"), new Guid("00000008-0000-0000-0000-000000000011"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 6, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 1, new DateTime(2026, 6, 8, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000054"), new Guid("00000008-0000-0000-0000-000000000011"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 8, 14, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 2, new DateTime(2026, 8, 9, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000055"), new Guid("00000008-0000-0000-0000-000000000011"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 10, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 3, new DateTime(2026, 10, 10, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000056"), new Guid("00000008-0000-0000-0000-000000000012"), new Guid("00000007-0000-0000-0000-000000000002"), new DateTime(2026, 2, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 4, new DateTime(2026, 2, 7, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000057"), new Guid("00000008-0000-0000-0000-000000000012"), new Guid("00000007-0000-0000-0000-000000000003"), new DateTime(2026, 4, 14, 0, 0, 0, 0, DateTimeKind.Unspecified), false, true, 1, new DateTime(2026, 4, 10, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000058"), new Guid("00000008-0000-0000-0000-000000000012"), new Guid("00000007-0000-0000-0000-000000000004"), new DateTime(2026, 6, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 2, new DateTime(2026, 6, 11, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000059"), new Guid("00000008-0000-0000-0000-000000000012"), new Guid("00000007-0000-0000-0000-000000000005"), new DateTime(2026, 8, 18, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 3, new DateTime(2026, 8, 12, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { new Guid("0000000b-0000-0000-0000-000000000060"), new Guid("00000008-0000-0000-0000-000000000012"), new Guid("00000007-0000-0000-0000-000000000001"), new DateTime(2026, 10, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), false, false, 4, new DateTime(2026, 10, 13, 0, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Reviews",
                columns: new[] { "Id", "AccommodationId", "Comment", "CustomerId", "IsDeleted", "Rating", "Satisfaction", "WouldRecommend" },
                values: new object[,]
                {
                    { new Guid("0000000c-0000-0000-0000-000000000001"), new Guid("00000008-0000-0000-0000-000000000001"), "Smještaj je tačno kako je opisan, domaćin se javio odmah i predaja ključeva je prošla bez čekanja.", new Guid("00000007-0000-0000-0000-000000000001"), false, 3, false, false },
                    { new Guid("0000000c-0000-0000-0000-000000000002"), new Guid("00000008-0000-0000-0000-000000000001"), "Čisto, tiho i blizu centra. Jedina zamjerka je parking koji se popuni rano popodne.", new Guid("00000007-0000-0000-0000-000000000002"), false, 4, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000003"), new Guid("00000008-0000-0000-0000-000000000002"), "Čisto, tiho i blizu centra. Jedina zamjerka je parking koji se popuni rano popodne.", new Guid("00000007-0000-0000-0000-000000000002"), false, 4, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000004"), new Guid("00000008-0000-0000-0000-000000000002"), "Odličan odnos cijene i kvaliteta, doručak bogat, osoblje ljubazno. Vraćamo se sigurno.", new Guid("00000007-0000-0000-0000-000000000003"), false, 5, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000005"), new Guid("00000008-0000-0000-0000-000000000003"), "Odličan odnos cijene i kvaliteta, doručak bogat, osoblje ljubazno. Vraćamo se sigurno.", new Guid("00000007-0000-0000-0000-000000000003"), false, 5, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000006"), new Guid("00000008-0000-0000-0000-000000000003"), "Sve je bilo uredno, ali grijanje je slabo radilo prve večeri dok domaćin nije došao i podesio ga.", new Guid("00000007-0000-0000-0000-000000000004"), false, 3, false, false },
                    { new Guid("0000000c-0000-0000-0000-000000000007"), new Guid("00000008-0000-0000-0000-000000000004"), "Sve je bilo uredno, ali grijanje je slabo radilo prve večeri dok domaćin nije došao i podesio ga.", new Guid("00000007-0000-0000-0000-000000000004"), false, 3, false, false },
                    { new Guid("0000000c-0000-0000-0000-000000000008"), new Guid("00000008-0000-0000-0000-000000000004"), "Pogled iz dnevnog boravka je stvarno kakav se vidi na fotografijama, preporučujem za par dana odmora.", new Guid("00000007-0000-0000-0000-000000000005"), false, 4, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000009"), new Guid("00000008-0000-0000-0000-000000000005"), "Pogled iz dnevnog boravka je stvarno kakav se vidi na fotografijama, preporučujem za par dana odmora.", new Guid("00000007-0000-0000-0000-000000000005"), false, 4, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000010"), new Guid("00000008-0000-0000-0000-000000000005"), "Kupatilo bi trebalo osvježiti, sve ostalo je bilo besprijekorno i dobili smo kasniji odjavni termin.", new Guid("00000007-0000-0000-0000-000000000001"), false, 5, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000011"), new Guid("00000008-0000-0000-0000-000000000006"), "Kupatilo bi trebalo osvježiti, sve ostalo je bilo besprijekorno i dobili smo kasniji odjavni termin.", new Guid("00000007-0000-0000-0000-000000000001"), false, 5, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000012"), new Guid("00000008-0000-0000-0000-000000000006"), "Smještaj je tačno kako je opisan, domaćin se javio odmah i predaja ključeva je prošla bez čekanja.", new Guid("00000007-0000-0000-0000-000000000002"), false, 3, false, false },
                    { new Guid("0000000c-0000-0000-0000-000000000013"), new Guid("00000008-0000-0000-0000-000000000007"), "Smještaj je tačno kako je opisan, domaćin se javio odmah i predaja ključeva je prošla bez čekanja.", new Guid("00000007-0000-0000-0000-000000000002"), false, 3, false, false },
                    { new Guid("0000000c-0000-0000-0000-000000000014"), new Guid("00000008-0000-0000-0000-000000000007"), "Čisto, tiho i blizu centra. Jedina zamjerka je parking koji se popuni rano popodne.", new Guid("00000007-0000-0000-0000-000000000003"), false, 4, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000015"), new Guid("00000008-0000-0000-0000-000000000008"), "Čisto, tiho i blizu centra. Jedina zamjerka je parking koji se popuni rano popodne.", new Guid("00000007-0000-0000-0000-000000000003"), false, 4, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000016"), new Guid("00000008-0000-0000-0000-000000000008"), "Odličan odnos cijene i kvaliteta, doručak bogat, osoblje ljubazno. Vraćamo se sigurno.", new Guid("00000007-0000-0000-0000-000000000004"), false, 5, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000017"), new Guid("00000008-0000-0000-0000-000000000009"), "Odličan odnos cijene i kvaliteta, doručak bogat, osoblje ljubazno. Vraćamo se sigurno.", new Guid("00000007-0000-0000-0000-000000000004"), false, 5, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000018"), new Guid("00000008-0000-0000-0000-000000000009"), "Sve je bilo uredno, ali grijanje je slabo radilo prve večeri dok domaćin nije došao i podesio ga.", new Guid("00000007-0000-0000-0000-000000000005"), false, 3, false, false },
                    { new Guid("0000000c-0000-0000-0000-000000000019"), new Guid("00000008-0000-0000-0000-000000000010"), "Sve je bilo uredno, ali grijanje je slabo radilo prve večeri dok domaćin nije došao i podesio ga.", new Guid("00000007-0000-0000-0000-000000000005"), false, 3, false, false },
                    { new Guid("0000000c-0000-0000-0000-000000000020"), new Guid("00000008-0000-0000-0000-000000000010"), "Pogled iz dnevnog boravka je stvarno kakav se vidi na fotografijama, preporučujem za par dana odmora.", new Guid("00000007-0000-0000-0000-000000000001"), false, 4, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000021"), new Guid("00000008-0000-0000-0000-000000000011"), "Pogled iz dnevnog boravka je stvarno kakav se vidi na fotografijama, preporučujem za par dana odmora.", new Guid("00000007-0000-0000-0000-000000000001"), false, 4, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000022"), new Guid("00000008-0000-0000-0000-000000000011"), "Kupatilo bi trebalo osvježiti, sve ostalo je bilo besprijekorno i dobili smo kasniji odjavni termin.", new Guid("00000007-0000-0000-0000-000000000002"), false, 5, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000023"), new Guid("00000008-0000-0000-0000-000000000012"), "Kupatilo bi trebalo osvježiti, sve ostalo je bilo besprijekorno i dobili smo kasniji odjavni termin.", new Guid("00000007-0000-0000-0000-000000000002"), false, 5, true, true },
                    { new Guid("0000000c-0000-0000-0000-000000000024"), new Guid("00000008-0000-0000-0000-000000000012"), "Smještaj je tačno kako je opisan, domaćin se javio odmah i predaja ključeva je prošla bez čekanja.", new Guid("00000007-0000-0000-0000-000000000003"), false, 3, false, false }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Administrators",
                keyColumn: "Id",
                keyValue: new Guid("00000005-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: new Guid("00000002-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: new Guid("00000002-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: new Guid("00000002-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: new Guid("00000002-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("0000000e-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("0000000e-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("0000000e-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("0000000e-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("0000000e-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("0000000e-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("0000000e-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("0000000e-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000009"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000010"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000011"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000012"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000013"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000014"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000015"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000016"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000017"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000018"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000019"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000020"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000021"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000022"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000023"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000024"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000025"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000026"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000027"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000028"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000029"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000030"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000031"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000032"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000033"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000034"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000035"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000036"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000037"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000038"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000039"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000040"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000041"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000042"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000043"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000044"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000045"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000046"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000047"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000048"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000049"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000050"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000051"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000052"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000053"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000054"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000055"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000056"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000057"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000058"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000059"));

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: new Guid("0000000b-0000-0000-0000-000000000060"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000009"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000010"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000011"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000012"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000013"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000014"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000015"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000016"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000017"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000018"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000019"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000020"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000021"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000022"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000023"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("0000000c-0000-0000-0000-000000000024"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000009"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000010"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000011"));

            migrationBuilder.DeleteData(
                table: "Accommodations",
                keyColumn: "Id",
                keyValue: new Guid("00000008-0000-0000-0000-000000000012"));

            migrationBuilder.DeleteData(
                table: "Chats",
                keyColumn: "Id",
                keyValue: new Guid("0000000d-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Chats",
                keyColumn: "Id",
                keyValue: new Guid("0000000d-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: new Guid("00000001-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: new Guid("00000001-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "Id",
                keyValue: new Guid("00000007-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "Id",
                keyValue: new Guid("00000007-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "Id",
                keyValue: new Guid("00000007-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "Id",
                keyValue: new Guid("00000007-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Customers",
                keyColumn: "Id",
                keyValue: new Guid("00000007-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000009"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000010"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000011"));

            migrationBuilder.DeleteData(
                table: "AccommodationDetails",
                keyColumn: "Id",
                keyValue: new Guid("00000009-0000-0000-0000-000000000012"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000009"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000010"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000011"));

            migrationBuilder.DeleteData(
                table: "AccommodationImages",
                keyColumn: "AccommodationImagesId",
                keyValue: new Guid("0000000a-0000-0000-0000-000000000012"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000009"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000010"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000011"));

            migrationBuilder.DeleteData(
                table: "Locations",
                keyColumn: "Id",
                keyValue: new Guid("00000003-0000-0000-0000-000000000012"));

            migrationBuilder.DeleteData(
                table: "Partners",
                keyColumn: "Id",
                keyValue: new Guid("00000006-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Partners",
                keyColumn: "Id",
                keyValue: new Guid("00000006-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Partners",
                keyColumn: "Id",
                keyValue: new Guid("00000006-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000009"));

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: new Guid("00000002-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: new Guid("00000002-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: new Guid("00000002-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: new Guid("00000002-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: new Guid("00000002-0000-0000-0000-000000000009"));

            migrationBuilder.DeleteData(
                table: "Cities",
                keyColumn: "Id",
                keyValue: new Guid("00000002-0000-0000-0000-000000000010"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("00000004-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: new Guid("00000001-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: new Guid("00000001-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: new Guid("00000001-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Countries",
                keyColumn: "Id",
                keyValue: new Guid("00000001-0000-0000-0000-000000000006"));
        }
    }
}
