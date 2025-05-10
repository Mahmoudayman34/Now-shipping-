import 'package:flutter/material.dart';
import 'package:tes1/features/business/orders/providers/order_details_provider.dart';
import 'package:tes1/features/business/orders/widgets/order_details/section_utilities.dart';

class ReturnDetailsSection extends StatelessWidget {
  final OrderDetailsModel orderDetails;

  const ReturnDetailsSection({
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
            title: 'Return Details',
            icon: Icons.assignment_return_outlined,
          ),
          const SizedBox(height: 16),
          
          // Number of Return Items
          DetailRow(
            label: 'Number of Items',
            value: '${orderDetails.returnItems ?? 0}',
          ),
          
          const SizedBox(height: 12),
          
          // Return Reason
          DetailRow(
            label: 'Return Reason',
            value: orderDetails.returnReason ?? 'N/A',
            maxLines: 2,
          ),
          
          const SizedBox(height: 12),
          
          // Return Items Description
          DetailRow(
            label: 'Item Description',
            value: orderDetails.returnProductDescription ?? 'N/A',
            maxLines: 3,
          ),
          
          // Cash on Delivery (refund if applicable)
          if (orderDetails.collectCashAmount > 0) ...[
            const SizedBox(height: 12),
            DetailRow(
              label: 'Refund Amount',
              value: '${orderDetails.collectCashAmount} EGP',
              isHighlighted: true,
            ),
          ],
        ],
      ),
    );
  }
}