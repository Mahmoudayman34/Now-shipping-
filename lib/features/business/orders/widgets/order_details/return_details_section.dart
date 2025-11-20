import 'package:flutter/material.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/section_utilities.dart';
import 'package:now_shipping/core/l10n/app_localizations.dart';

class ReturnDetailsSection extends StatelessWidget {
  final OrderDetailsModel orderDetails;

  const ReturnDetailsSection({
    super.key,
    required this.orderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: AppLocalizations.of(context).returnDetails,
            icon: Icons.assignment_return_outlined,
          ),
          const SizedBox(height: 16),
          
          // Number of Return Items
          DetailRow(
            label: AppLocalizations.of(context).numberOfItems,
            value: '${orderDetails.returnItems ?? orderDetails.numberOfItems ?? 1}',
          ),
          
          const SizedBox(height: 12),
          
          // Return Reason
          DetailRow(
            label: AppLocalizations.of(context).returnReason,
            value: orderDetails.returnReason ?? AppLocalizations.of(context).na,
            maxLines: 2,
          ),
          
          const SizedBox(height: 12),
          
          // Return Items Description
          DetailRow(
            label: AppLocalizations.of(context).productDescription,
            value: orderDetails.returnProductDescription ?? AppLocalizations.of(context).na,
            maxLines: 3,
          ),
          
          // Cash on Delivery (refund if applicable)
          if (orderDetails.collectCashAmount > 0) ...[
            const SizedBox(height: 12),
            DetailRow(
              label: AppLocalizations.of(context).refund,
              value: '${orderDetails.collectCashAmount} ${AppLocalizations.of(context).egp}',
              isHighlighted: true,
            ),
          ],
        ],
      ),
    );
  }
}