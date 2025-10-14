import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/screens/edit_order_screen.dart';
import '../../../../core/l10n/app_localizations.dart';

class EditOrderFeeSummaryWidget extends ConsumerWidget {
  const EditOrderFeeSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the fee from the edit order fee provider
    final deliveryFee = ref.watch(editOrderFeeProvider);
    
    // Log when fee changes
    ref.listen<double>(editOrderFeeProvider, (previous, current) {
      if (previous != current) {
        print('DEBUG FEE SUMMARY: Fee updated from $previous to $current');
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          AppLocalizations.of(context).deliveryFeeSummary,
          style: const TextStyle(
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
          child: _buildFeeDisplay(context, deliveryFee),
        ),
      ],
    );
  }
  
  Widget _buildFeeDisplay(BuildContext context, double deliveryFee) {
    return Column(
      children: [
        // Fee amount
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (deliveryFee <= 0)
              Text(
                'Calculating...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade700,
                ),
              )
            else ...[
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
            ]
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Total delivery fee text
        Text(
          AppLocalizations.of(context).totalDeliveryFee,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.orange.shade700,
          ),
        ),
        
        if (deliveryFee <= 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
              ),
            ),
          ),
      ],
    );
  }
} 