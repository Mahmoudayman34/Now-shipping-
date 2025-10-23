import 'package:flutter/material.dart';
import 'package:now_shipping/core/utils/status_colors.dart';
import 'package:now_shipping/core/utils/order_status_helper.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/section_utilities.dart';
import '../../../../../core/l10n/app_localizations.dart';

class AdditionalDetailsSection extends StatelessWidget {
  final OrderDetailsModel orderDetails;

  const AdditionalDetailsSection({
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
            title: AppLocalizations.of(context).additionalDetails,
            icon: Icons.info_outline,
          ),
          const SizedBox(height: 16),
          
          // Order Status with description
          DetailRow(
            label: AppLocalizations.of(context).status,
            value: orderDetails.statusLabel ?? OrderStatusHelper.getLocalizedStatus(context, orderDetails.status),
            valueColor: StatusColors.getTextColorFromStatus(orderDetails.status),
          ),
          
          // Status Description if available
          if (orderDetails.statusDescription != null && orderDetails.statusDescription!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                orderDetails.statusDescription!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Order Fees
          DetailRow(
            label: 'Order Fees',
            value: '${orderDetails.orderFees.toStringAsFixed(2)} EGP',
          ),
          
          const SizedBox(height: 12),
          
          // Date created
          DetailRow(
            label: AppLocalizations.of(context).dateCreated,
            value: orderDetails.createdAt,
          ),
          
          // Completed Date if available
          if (orderDetails.completedDate != null) ...[
            const SizedBox(height: 12),
            DetailRow(
              label: 'Completed Date',
              value: orderDetails.completedDate!,
              valueColor: Colors.green.shade700,
            ),
          ],
          
          // Delivery Man if assigned
          if (orderDetails.deliveryManName != null) ...[
            const SizedBox(height: 12),
            DetailRow(
              label: 'Delivery Person',
              value: orderDetails.deliveryManName!,
            ),
          ],
          
          // Progress Percentage if available
          if (orderDetails.progressPercentage != null) ...[
            const SizedBox(height: 12),
            DetailRow(
              label: 'Progress',
              value: '${orderDetails.progressPercentage}%',
            ),
          ],
          
          // Return-specific fields
          if (orderDetails.deliveryType == 'Return') ...[
            if (orderDetails.originalOrderNumber != null) ...[
              const SizedBox(height: 12),
              DetailRow(
                label: 'Original Order',
                value: orderDetails.originalOrderNumber!,
                valueColor: Colors.blue.shade700,
              ),
            ],
            if (orderDetails.returnReason != null && orderDetails.returnReason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              DetailRow(
                label: 'Return Reason',
                value: orderDetails.returnReason!,
                maxLines: 2,
              ),
            ],
            if (orderDetails.returnNotes != null && orderDetails.returnNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              DetailRow(
                label: 'Return Notes',
                value: orderDetails.returnNotes!,
                maxLines: 3,
              ),
            ],
            if (orderDetails.isPartialReturn == true) ...[
              const SizedBox(height: 12),
              DetailRow(
                label: 'Return Type',
                value: 'Partial Return (${orderDetails.partialReturnItemCount ?? 0} items)',
                valueColor: Colors.orange.shade700,
              ),
            ],
          ],
          
          // Special Instructions if available
          if (orderDetails.deliveryNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            DetailRow(
              label: AppLocalizations.of(context).specialInstructions,
              value: orderDetails.deliveryNotes,
              maxLines: 3,
            ),
          ],
          
          // Reference Number if available
          if (orderDetails.orderReference.isNotEmpty) ...[
            const SizedBox(height: 12),
            DetailRow(
              label: AppLocalizations.of(context).referenceNumber,
              value: orderDetails.orderReference,
            ),
          ],
        ],
      ),
    );
  }

}