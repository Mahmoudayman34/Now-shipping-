# Security Remediation Steps

## Google API Key Leak - Remediation Guide

GitHub detected a leaked Google API key in your repository. Follow these steps to remediate:

### Immediate Actions Required

#### 1. Rotate the API Key in Firebase Console
   - Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
   - Navigate to your Firebase project: `now-shipping-9a90f`
   - Find the API key: `AIzaSyB7OshcBMb4rFru3Hq9SxAcWSRnFqtdZCo`
   - **Revoke/Delete** the old key
   - **Create a new API key** for iOS
   - **Restrict the new key** to only allow requests from your iOS app bundle ID: `co.nowshipping.now`

#### 2. Regenerate Firebase Configuration Files
   After rotating the key, regenerate your Firebase configuration files:

   ```bash
   # Install FlutterFire CLI if not already installed
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your project
   flutterfire configure
   ```

   This will regenerate:
   - `lib/firebase_options.dart`
   - `ios/Runner/GoogleService-Info.plist`
   - `android/app/google-services.json`

#### 3. Remove Exposed Files from Git History
   The files have been added to `.gitignore`, but you need to remove them from Git history:

   ```bash
   # Remove the files from Git tracking (they're now in .gitignore)
   git rm --cached ios/Runner/GoogleService-Info.plist
   git rm --cached android/app/google-services.json
   
   # Commit the removal
   git commit -m "Remove sensitive Firebase config files from version control"
   ```

   **Note:** If this is a public repository, consider using `git-filter-repo` or BFG Repo-Cleaner to completely remove the keys from Git history.

#### 4. Check Security Logs
   - Review Firebase usage logs in [Firebase Console](https://console.firebase.google.com/)
   - Check for any unauthorized access or unusual activity
   - Monitor API usage for the exposed key period

#### 5. Close the GitHub Alert
   After completing the above steps:
   - Mark the alert as "Revoked" in GitHub
   - Verify that the new key is properly restricted

### Security Best Practices Implemented

✅ **Added to `.gitignore`:**
   - `ios/Runner/GoogleService-Info.plist`
   - `android/app/google-services.json`
   - `lib/config/secrets.dart`

✅ **Created template files:**
   - `ios/Runner/GoogleService-Info.plist.example`
   - `android/app/google-services.json.example`

### Important Notes

- **Firebase API Keys are client-side keys** and are typically meant to be public, but they should be:
  - Restricted to specific app bundle IDs
  - Protected by Firebase Security Rules
  - Not committed to public repositories without proper restrictions

- **For team members:** After pulling this update, copy the `.example` files to their actual names and fill in your Firebase project credentials.

### Next Steps

1. ✅ Rotate the API key in Google Cloud Console
2. ✅ Regenerate Firebase configuration files
3. ✅ Remove files from Git history
4. ✅ Review security logs
5. ✅ Close GitHub alert

---

**Last Updated:** After security remediation
**Status:** In Progress - Requires manual key rotation in Firebase Console


