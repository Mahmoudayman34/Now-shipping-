import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  /// Request storage permissions for downloading and saving files
  static Future<bool> requestStoragePermissions(BuildContext context) async {
    try {
      // For Android 13+ (API 33+), we need to request media permissions
      if (await _isAndroid13OrHigher()) {
        // Request media permissions for Android 13+
        final mediaImagesStatus = await Permission.photos.request();
        final mediaVideoStatus = await Permission.videos.request();
        final mediaAudioStatus = await Permission.audio.request();
        final mediaDocumentsStatus = await Permission.mediaLibrary.request();
        
        if (mediaImagesStatus.isGranted || mediaVideoStatus.isGranted || 
            mediaAudioStatus.isGranted || mediaDocumentsStatus.isGranted) {
          return true;
        }
      } else {
        // For older Android versions, request storage permissions
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          return true;
        }
      }
      
      // If permissions are denied, show dialog to user
      if (context.mounted) {
        await _showPermissionDeniedDialog(context);
      }
      
      return false;
    } catch (e) {
      print('Error requesting storage permissions: $e');
      return false;
    }
  }
  
  /// Check if we're running on Android 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    try {
      // Check if photos permission is available (Android 13+)
      final photosStatus = await Permission.photos.status;
      return photosStatus != PermissionStatus.denied;
    } catch (e) {
      return false;
    }
  }
  
  /// Show dialog when permissions are denied
  static Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text(
            'This app needs storage permission to save Excel files to your device. '
            'Please grant permission in your device settings to continue.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
  
  /// Check if storage permissions are already granted
  static Future<bool> hasStoragePermissions() async {
    try {
      if (await _isAndroid13OrHigher()) {
        // Check media permissions for Android 13+
        final mediaImagesStatus = await Permission.photos.status;
        final mediaVideoStatus = await Permission.videos.status;
        final mediaAudioStatus = await Permission.audio.status;
        final mediaDocumentsStatus = await Permission.mediaLibrary.status;
        
        return mediaImagesStatus.isGranted || 
               mediaVideoStatus.isGranted || 
               mediaAudioStatus.isGranted ||
               mediaDocumentsStatus.isGranted;
      } else {
        // Check storage permission for older Android versions
        final storageStatus = await Permission.storage.status;
        return storageStatus.isGranted;
      }
    } catch (e) {
      print('Error checking storage permissions: $e');
      return false;
    }
  }
}
