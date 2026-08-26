FROM mcr.microsoft.com/dotnet/aspnet:8.0 as base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 as build

COPY ebooking-api/PaymentApp /src/PaymentApp
COPY ebooking-api/Authentication /src/Authentication
COPY ebooking-api/Models /src/Models
COPY ebooking-api/Database /src/Database

WORKDIR /src
RUN dotnet build "PaymentApp/PaymentApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "PaymentApp/PaymentApp.csproj" -c Release -o /app/publish

FROM base as final
WORKDIR /app
COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "PaymentApp.dll"]