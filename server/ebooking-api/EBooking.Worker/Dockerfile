FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
COPY ebooking-api/EBooking.Worker /src/EBooking.Worker
COPY ebooking-api/Models /src/Models
COPY ebooking-api/Database /src/Database

WORKDIR /src

RUN dotnet publish "EBooking.Worker/EBooking.Worker.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "EBooking.Worker.dll"]
