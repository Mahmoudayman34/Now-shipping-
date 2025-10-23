import 'package:flutter/material.dart';

class CancelOrderButton extends StatelessWidget {
  final String orderId;
  final VoidCallback onCancel;

  const CancelOrderButton({
    super.key,
    required this.orderId,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.cancel_outlined, size: 20),
          label: const Text('Cancel Order'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }
}
