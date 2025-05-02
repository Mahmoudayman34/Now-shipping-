import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for delivery fee calculation
final deliveryFeeProvider = Provider<double>((ref) {
  // Here you would implement logic to calculate the delivery fee based on order details
  // For now, returning a fixed value
  return 0.0;
});

class DeliveryFeeSummaryWidget extends ConsumerWidget {
  const DeliveryFeeSummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryFee = ref.watch(deliveryFeeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Delivery Fee Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xff2F2F2F),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Orange highlighted container with fee information
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5E6), // Light orange background color
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Fee amount
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    deliveryFee.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'EGP',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Total delivery fee text
              Text(
                'Total Delivery Fee',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}