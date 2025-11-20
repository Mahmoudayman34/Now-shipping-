import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationPermissionHelper {
  /// Check notification permissions and show dialog if denied
  static Future<void> checkPermissions(BuildContext context) async {
    if (!context.mounted) return;

    PermissionStatus status;

    if (Platform.isAndroid) {
      // Check notification permission for Android 13+
      status = await Permission.notification.status;
    } else if (Platform.isIOS) {
      // Check notification permission for iOS
      status = await Permission.notification.status;
    } else {
      // Other platforms
      return;
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      if (context.mounted) {
        await showPermissionDialog(context);
      }
    }
  }

  /// Request notification permission
  static Future<PermissionStatus> requestPermission() async {
    return await Permission.notification.request();
  }

  /// Show permission explanation dialog
  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xfff29620).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Color(0xfff29620),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Enable Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stay updated with your orders and deliveries!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Allow notifications to receive:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              _PermissionBenefit(
                icon: Icons.local_shipping_outlined,
                text: 'Order status updates',
              ),
              SizedBox(height: 8),
              _PermissionBenefit(
                icon: Icons.notifications_outlined,
                text: 'New order alerts',
              ),
              SizedBox(height: 8),
              _PermissionBenefit(
                icon: Icons.info_outline,
                text: 'Important announcements',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Not Now',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfff29620),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    try {
      if (Platform.isIOS) {
        // iOS: Open app settings
        final uri = Uri.parse('app-settings:');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          // Fallback to permission_handler's method
          await openAppSettings();
        }
      } else {
        // Android: Use permission_handler's method
        await Permission.notification.request();
      }
    } catch (e) {
      debugPrint('❌ Error opening app settings: $e');
    }
  }
}

class _PermissionBenefit extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PermissionBenefit({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xfff29620),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

