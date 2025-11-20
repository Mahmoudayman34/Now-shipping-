import 'package:flutter/material.dart';

class PermissionService {
  /// Request storage permissions for downloading and saving files
  /// 
  /// NOTE: This method now always returns true because:
  /// - Image selection uses Android Photo Picker (no permissions needed on Android 13+)
  /// - Excel export uses share_plus which doesn't require storage permissions
  /// - Files are saved to app documents directory and shared via system share dialog
  static Future<bool> requestStoragePermissions(BuildContext context) async {
    // No permissions needed - Photo Picker and share_plus handle file access
    return true;
  }
  
  /// Check if storage permissions are already granted
  /// 
  /// NOTE: This method now always returns true because we don't need storage permissions.
  /// See requestStoragePermissions() for details.
  static Future<bool> hasStoragePermissions() async {
    // No permissions needed - Photo Picker and share_plus handle file access
    return true;
  }
}
