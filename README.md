# eBooking - Seminarski Razvoj Softvera 2

[![.NET CI](https://github.com/cuteghost/RS2-Seminarski/actions/workflows/dotnet-ci.yml/badge.svg?branch=master)](https://github.com/cuteghost/RS2-Seminarski/actions/workflows/dotnet-ci.yml)
[![Flutter CI](https://github.com/cuteghost/RS2-Seminarski/actions/workflows/flutter-ci.yml/badge.svg?branch=master)](https://github.com/cuteghost/RS2-Seminarski/actions/workflows/flutter-ci.yml)
[![Secrets Scan](https://github.com/cuteghost/RS2-Seminarski/actions/workflows/secrets-scan.yml/badge.svg?branch=master)](https://github.com/cuteghost/RS2-Seminarski/actions/workflows/secrets-scan.yml)

## Prerequisites

Before running the application, ensure you have the following installed:

- **Docker** & **Docker Compose** (for backend services)
- **Flutter SDK** 3.24.0 or higher
- **Dart SDK** 3.5.0 or higher
- **Windows OS** (for desktop version)
- **Two Android Emulators** or physical devices (for mobile version)

## Running the Application

### 1. Backend Services (Docker Compose)

The backend consists of multiple services: REST API, Messenger (SignalR), Payment Service, RabbitMQ, and MSSQL Database.

```bash
# Navigate to backend directory
cd backend

# Create .env file from template (if not exists)
cp .env.example .env

# Edit .env file and add your secrets (DB credentials, JWT keys, PayPal API keys, OAuth credentials)

# Build and start all services
docker-compose up -d

# Check if all services are running
docker-compose ps

```

**Backend Services will be available on:**
- REST API: http://localhost:9999
- Messenger (SignalR): http://localhost:8888
- Payment Service: http://localhost:6666
- RabbitMQ Management: http://localhost:15672
- MSSQL Database: localhost:7777

### 2. Desktop Application (Flutter Windows)

```bash
# Navigate to desktop directory
cd desktop

# Get dependencies
flutter pub get

# Run the application
flutter run -d windows
```

### 3. Mobile Application (Flutter Android)
#### Prerequisites
```bash
# Navigate to android directory
cd client/mobile

# Create local.properties file from template (if not exists)
cp android/local.properties.example android/local.properties

# Edit local.properties and add your API keys (Facebook, Google)

# Get dependencies
flutter pub get
# List devices 
# YOU MUST HAVE TWO EMULATORS TO TEST FUNCTIONALITIES
flutter emulators
    #Example output
    # 2 available emulators:
    # Id      • Name    • Manufacturer • Platform

    # Klijent • Klijent • Google       • android
    # Partner • Partner • Google       • android

# If you miss emulators you can create them with
avdmanager create avd -n Partner -k "system-images;android-34;google_apis;x86_64" --device "pixel"

avdmanager create avd -n Klijent -k "system-images;android-34;google_apis;x86_64" --device "pixel"
# !!! NOTE: Make sure that the sdk tools are in the path to use this command, otherwise they won't work
```
#### Run application
```
# Run the application on connected device/emulator
flutter run

```

## Credentials

### Application Access

#### Desktop Version (Administrator Role)
- **Username:** desktop
- **Password:** test

**Alternative Administrator Account:**
- Email: admin@ebooking.com
- Password: Stringst

#### Mobile Version (Customer Role)
- **Username:** mobile  
- **Password:** test

**Alternative Customer Account:**
- Email: dea@email.com
- Password: Stringst

#### Mobile Version (Partner Role)
- **Username:** partner
- **Password:** test

**Alternative Partner Account:**
- Email: dude@email.com
- Password: Stringst

## OAuth Testing

To test OAuth with Google and Facebook, use the following credentials:

### Google OAuth
- Email: razvojsoftveradva@gmail.com
- Password: Stringst  

### Facebook OAuth
- Email: razvojsoftverafacebook@gmail.com
- Password: Stringst

## Payment Testing (PayPal Sandbox)

### Credit Card for Testing
- **Credit Card Number:** 4032 0350 3641 8515
- **Expiry Date:** 08/2025
- **CVC Code:** 885

Rest of the data fields can be dummy data.

### PayPal Business Account (Verify Payments)
After successful reservation, verify the payment at https://www.sandbox.paypal.com/signin:

- **Email:** sb-ychoj31063636@business.example.com
- **Password:** 8&@nB?bz

After each reservation, the amount should be reflected in the account.

## Google Maps Testing (Nearby Accommodations)

On a mobile device or emulator, set the location to **Sarajevo**. This allows the "Nearby Accommodations" feature to find all accommodations within close proximity (10 kilometers).

## RabbitMQ Testing (Messaging)

To test the RabbitMQ implementation:
1. Use a **Customer account** to make a reservation
2. After the reservation is made, an automatic **Welcome message** is sent from the Owner (Partner) to the Customer via RabbitMQ message queue

You can monitor RabbitMQ messages at http://localhost:15672 (credentials from .env file).

## Architecture & Tech Stack

### Server Side (.NET 8.0 LTS)
- **ASP.NET Core** 8.0 - REST API
- **SignalR** - Real-time messaging
- **Entity Framework Core** 8.0 - ORM
- **MSSQL Server** 2019 - Database
- **RabbitMQ** - Message broker (EasyNetQ)
- **PayPal SDK** - Payment processing
- **Docker** - Containerization
- **OAuth 2.0** - Facebook & Google authentication

### Client Side
- **Flutter** 3.24.0 / Dart 3.5.0
- **Provider** - State management
- **SignalR Client** - Real-time communication
- **Google Maps** - Location services
- **OAuth 2.0** - Facebook & Google authentication

### CI/CD & Security
- **GitHub Actions** - Automated testing and quality checks
- **Gitleaks** - Secrets scanning
- **ProGuard/R8** - Android code obfuscation
- **Environment Variables** - Secure configuration management

## Project Structure

```
e-Booking/
├── server/
│   ├── docker-compose.yaml          # Docker orchestration
│   ├── .env                          # Backend secrets (not in git)
│   └── ebooking-api/
│       ├── API/                      # REST API service
│       ├── Messenger/                # SignalR service
│       ├── PaymentApp/               # Payment service
│       ├── Database/                 # EF Core context & migrations
│       ├── Models/                   # Domain models & DTOs
│       └── Authentication/           # JWT & auth services
├── client
│    ├── mobile/
│    │   ├── lib/                          # Flutter mobile app source
│    │   ├── android/
│    │   │   ├── local.properties          # Android secrets (not in git)
│    │   │   └── app/
│    │   │       ├── proguard-rules.pro    # Code obfuscation rules
│    │   │       └── build.gradle          # BuildConfig fields
│    │   └── pubspec.yaml
│    ├── desktop/
│    │   ├── lib/                          # Flutter desktop app source
│    │   └── pubspec.yaml
└── .github/
    └── workflows/                    # CI/CD pipelines
        ├── dotnet-ci.yml             # .NET build & format checks
        ├── flutter-ci.yml            # Flutter analyze & format
        └── secrets-scan.yml          # Automated secrets scanning
```

## Security

This project implements multiple security best practices:

- [x] **No hardcoded secrets** - All sensitive data in environment variables
- [x] **.gitignore** - Prevents committing `.env`, `local.properties`, keystores
- [x] **ProGuard/R8** - Android APK code obfuscation
- [x] **BuildConfig** - Compile-time secret injection for Android
- [x] **Gitleaks** - Automated secret scanning in CI/CD

## Notes

- The database backup is automatically restored on first run from `backend/database/backup/`
- ML.NET recommendation model is trained on application startup
- RabbitMQ message broker handles asynchronous notifications
- All .NET services run in separate Docker containers
- Flutter apps connect to backend services via localhost ports




