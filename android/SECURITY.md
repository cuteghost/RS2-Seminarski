# Android Security Configuration

## API Keys & Secrets Management

This project uses **BuildConfig fields** and **local.properties** to securely manage API keys and secrets.

### Setup Instructions

1. **Copy the template file:**
   ```bash
   cp android/local.properties.example android/local.properties
   ```

2. **Fill actual API keys in `android/local.properties`:**
   ```properties
   facebook.app.id=YOUR_FACEBOOK_APP_ID
   facebook.client.token=YOUR_FACEBOOK_CLIENT_TOKEN
   google.api.key=YOUR_GOOGLE_API_KEY
   ```

3. **Never commit `local.properties`** - it's already in `.gitignore`

### How It Works

1. **Build Time Injection**: Secrets are loaded from `local.properties` during build
2. **BuildConfig Fields**: Values are compiled into BuildConfig class (obfuscated in release)
3. **Manifest Placeholders**: Secrets are injected into AndroidManifest.xml at build time
4. **Code Obfuscation**: Release builds use ProGuard/R8 to obfuscate code and make reverse engineering difficult

### Security Features

**No hardcoded secrets** in source code or XML files  
**ProGuard/R8 enabled** for release builds (code obfuscation)  
**Resource shrinking** enabled to remove unused resources  
**local.properties** in .gitignore (never committed)  
**Secrets not easily extractable** from APK without significant reverse engineering effort

### Build Commands

**Debug build** (no obfuscation):
```bash
flutter build apk --debug
```

**Release build** (with obfuscation):
```bash
flutter build apk --release
```

### Notes

- Never commit API keys to version control
