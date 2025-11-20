# Google Play Release Guide

This guide will help you prepare and upload a new release to Google Play Store.

## Current Version
- **Version Name**: 1.0.6
- **Version Code**: 6
- **Application ID**: co.nowshipping.nowshipping

## Pre-Release Checklist

### 1. Version Increment
Before building a new release, you need to increment the version numbers:

**Option A: Increment Patch Version (1.0.6 → 1.0.7)**
- Update `pubspec.yaml`: `version: 1.0.7+7`
- Update `android/local.properties`: 
  - `flutter.versionName=1.0.7`
  - `flutter.versionCode=7`

**Option B: Increment Minor Version (1.0.6 → 1.1.0)**
- Update `pubspec.yaml`: `version: 1.1.0+7`
- Update `android/local.properties`:
  - `flutter.versionName=1.1.0`
  - `flutter.versionCode=7`

**Option C: Increment Major Version (1.0.6 → 2.0.0)**
- Update `pubspec.yaml`: `version: 2.0.0+7`
- Update `android/local.properties`:
  - `flutter.versionName=2.0.0`
  - `flutter.versionCode=7`

**Important**: The version code must always be higher than the previous release on Google Play.

### 2. Update Changelog
Update `CHANGELOG.md` with the new version and changes.

### 3. Verify Signing Configuration
✅ Signing is already configured:
- Keystore: `android/app/upload-keystore.jks`
- Key alias: `upload`
- Configuration file: `android/key.properties`

## Building the Release

### Step 1: Clean Previous Builds
```bash
flutter clean
```

### Step 2: Get Dependencies
```bash
flutter pub get
```

### Step 3: Build Android App Bundle (AAB)
Google Play requires an AAB (Android App Bundle) file, not an APK.

```bash
flutter build appbundle --release
```

The AAB file will be generated at:
```
build/app/outputs/bundle/release/app-release.aab
```

### Alternative: Build APK (for testing)
If you need an APK for testing before uploading:
```bash
flutter build apk --release
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Uploading to Google Play

### Step 1: Access Google Play Console
1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app: **Now Shipping** (co.nowshipping.nowshipping)

### Step 2: Create New Release
1. Navigate to **Production** (or **Testing** track)
2. Click **Create new release**
3. Upload the AAB file: `build/app/outputs/bundle/release/app-release.aab`

### Step 3: Release Notes
Add release notes describing what's new in this version. You can copy from `CHANGELOG.md`.

### Step 4: Review and Rollout
1. Review the release details
2. Click **Save** then **Review release**
3. After review, click **Start rollout to Production** (or appropriate track)

## Important Notes

⚠️ **Security**: 
- Never commit `key.properties` or `upload-keystore.jks` to version control
- These files are already in `.gitignore`

⚠️ **Version Code**:
- Each release must have a unique, incrementing version code
- Google Play will reject uploads with version codes that are not higher than the previous release

⚠️ **Testing**:
- Consider uploading to **Internal testing** or **Closed testing** first
- Test thoroughly before rolling out to production

## Troubleshooting

### Build Fails
- Ensure Flutter SDK is up to date: `flutter upgrade`
- Clean and rebuild: `flutter clean && flutter pub get`
- Check for any linter errors: `flutter analyze`

### Signing Issues
- Verify `android/key.properties` exists and has correct paths
- Ensure `upload-keystore.jks` exists at the specified path
- Check that passwords in `key.properties` are correct

### Upload Rejected
- Verify version code is higher than previous release
- Check that all required permissions are declared in `AndroidManifest.xml`
- Ensure target SDK version meets Google Play requirements (currently set to 35)

## Quick Commands Summary

```bash
# Clean and prepare
flutter clean
flutter pub get

# Build release AAB
flutter build appbundle --release

# Build release APK (for testing)
flutter build apk --release

# Check app size
flutter build appbundle --release --analyze-size
```


