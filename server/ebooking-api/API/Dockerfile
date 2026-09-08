FROM mcr.microsoft.com/dotnet/aspnet:8.0 as base
WORKDIR /app

RUN apt-get update && \
    apt-get install -y netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

FROM mcr.microsoft.com/dotnet/sdk:8.0 as build
COPY ebooking-api/API /src/API
COPY ebooking-api/Authentication /src/Authentication
COPY ebooking-api/Models /src/Models
COPY ebooking-api/Database /src/Database

WORKDIR /src

RUN dotnet build "API/API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "API/API.csproj" -c Release -o /app/publish

FROM base as final
WORKDIR /app
COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "API.dll"]