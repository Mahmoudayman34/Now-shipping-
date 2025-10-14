import 'package:flutter/material.dart';
import '../../../core/widgets/app_dialog.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      message: message,
      confirmText: onRetry != null ? 'Retry' : 'Close',
      cancelText: onRetry != null ? 'Close' : 'Cancel',
      onConfirm: onRetry != null
          ? () {
              Navigator.of(context).pop();
              onRetry!();
            }
          : () => Navigator.of(context).pop(),
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  // Helper method to show the dialog
  static Future<void> show(
    BuildContext context, {
    String title = 'Error',
    required String message,
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
      ),
    );
  }
}
