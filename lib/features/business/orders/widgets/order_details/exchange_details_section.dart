import 'package:flutter/material.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/section_utilities.dart';
import '../../../../../core/l10n/app_localizations.dart';

class ExchangeDetailsSection extends StatelessWidget {
  final OrderDetailsModel orderDetails;

  const ExchangeDetailsSection({
    Key? key,
    required this.orderDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Exchange Details',
            icon: Icons.swap_horiz_outlined,
          ),
          const SizedBox(height: 16),
          
          // Current Items section
          const Text(
            'Current Items (To Be Collected)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2F2F2F),
            ),
          ),
          const SizedBox(height: 8),
          
          // Number of Current Items
          DetailRow(
            label: 'Number of Items',
            value: '${orderDetails.currentItems ?? 0}',
          ),
          
          const SizedBox(height: 12),
          
          // Current Item Description
          DetailRow(
            label: 'Item Description',
            value: orderDetails.currentProductDescription ?? 'N/A',
            maxLines: 3,
          ),
          
          const Divider(height: 32),
          
          // New Items section
          const Text(
            'New Items (To Be Delivered)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2F2F2F),
            ),
          ),
          const SizedBox(height: 8),
          
          // Number of New Items
          DetailRow(
            label: 'Number of Items',
            value: '${orderDetails.newItems ?? 0}',
          ),
          
          const SizedBox(height: 12),
          
          // New Item Description
          DetailRow(
            label: 'Item Description',
            value: orderDetails.newProductDescription ?? 'N/A',
            maxLines: 3,
          ),
          
          const SizedBox(height: 12),
          
          // Cash on Delivery (if applicable)
          if (orderDetails.collectCashAmount > 0) ...[
            const SizedBox(height: 12),
            DetailRow(
              label: 'Cash on Delivery',
              value: '${orderDetails.collectCashAmount} EGP',
              isHighlighted: true,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Allow Opening Package
          Row(
            children: [
              Icon(
                orderDetails.allowOpeningPackage
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank,
                color: const Color(0xFF26A2B9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).allowCustomerInspect,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2F2F2F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}