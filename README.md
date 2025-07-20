# Now Shipping App

A new Flutter project for shipping and logistics management.

## Getting Started

This project is a starting point for a Flutter application.

### API Keys Setup

This app requires API keys to function properly. Follow these steps:

#### 1. Flutter/Dart Configuration
```bash
cp lib/config/secrets.dart.example lib/config/secrets.dart
```
Edit `lib/config/secrets.dart` and add your actual API keys.

#### 2. Android Configuration
```bash
cp android/local.properties.example android/local.properties
```
Edit `android/local.properties` and add your Google Maps API key.

#### 3. iOS Configuration
```bash
cp ios/Runner/Config.xcconfig.example ios/Runner/Config.xcconfig
```
Edit `ios/Runner/Config.xcconfig` and add your Google Maps API key.

#### 4. Google Maps API Setup
- **Get API Key**: [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
- **Enable APIs**:
  - Maps SDK for Android
  - Maps SDK for iOS
  - Places API
  - Geocoding API
- **Configure Restrictions**: Add your app's bundle ID and package name

#### 5. Security Note
**Never commit these files to version control:**
- `lib/config/secrets.dart`
- `android/local.properties` 
- `ios/Runner/Config.xcconfig`

All are already in `.gitignore`.

### Development Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Resources

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
