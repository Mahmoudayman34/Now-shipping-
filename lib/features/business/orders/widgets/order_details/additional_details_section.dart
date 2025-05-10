import 'package:flutter/material.dart';
import 'package:tes1/core/utils/status_colors.dart';
import 'package:tes1/features/business/orders/providers/order_details_provider.dart';
import 'package:tes1/features/business/orders/widgets/order_details/section_utilities.dart';

class AdditionalDetailsSection extends StatelessWidget {
  final OrderDetailsModel orderDetails;

  const AdditionalDetailsSection({
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
            title: 'Additional Details',
            icon: Icons.info_outline,
          ),
          const SizedBox(height: 16),
          
          // Special Instructions if available
          if (orderDetails.deliveryNotes.isNotEmpty)
            DetailRow(
              label: 'Special Instructions',
              value: orderDetails.deliveryNotes,
              maxLines: 3,
            ),
          
          // Reference Number if available
          if (orderDetails.orderReference.isNotEmpty) ...[
            const SizedBox(height: 12),
            DetailRow(
              label: 'Reference Number',
              value: orderDetails.orderReference,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Date created
          DetailRow(
            label: 'Date Created',
            value: orderDetails.createdAt,
          ),
          
          const SizedBox(height: 12),
          
          // Order Status
          DetailRow(
            label: 'Status',
            value: orderDetails.status,
            valueColor: StatusColors.getTextColor(orderDetails.status),
          ),
        ],
      ),
    );
  }
}