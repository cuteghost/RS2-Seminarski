FROM mcr.microsoft.com/dotnet/aspnet:8.0 as base
WORKDIR /app

RUN apt-get update && apt-get install -y netcat-openbsd

FROM mcr.microsoft.com/dotnet/sdk:8.0 as build
COPY ebooking-api/Messenger /src/Messenger
COPY ebooking-api/Authentication /src/Authentication
COPY ebooking-api/Models /src/Models
COPY ebooking-api/Database /src/Database

WORKDIR /src

RUN dotnet build "Messenger/Messenger.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Messenger/Messenger.csproj" -c Release -o /app/publish

FROM base as final
WORKDIR /app
COPY --from=publish /app/publish .


ENTRYPOINT ["dotnet", "Messenger.dll"]