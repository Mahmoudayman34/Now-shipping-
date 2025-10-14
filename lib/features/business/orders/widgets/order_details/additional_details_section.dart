import 'package:flutter/material.dart';
import 'package:now_shipping/core/utils/status_colors.dart';
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
          
          // Special Instructions if available
          if (orderDetails.deliveryNotes.isNotEmpty)
            DetailRow(
              label: AppLocalizations.of(context).specialInstructions,
              value: orderDetails.deliveryNotes,
              maxLines: 3,
            ),
          
          // Reference Number if available
          if (orderDetails.orderReference.isNotEmpty) ...[
            const SizedBox(height: 12),
            DetailRow(
              label: AppLocalizations.of(context).referenceNumber,
              value: orderDetails.orderReference,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Date created
          DetailRow(
            label: AppLocalizations.of(context).dateCreated,
            value: orderDetails.createdAt,
          ),
          
          const SizedBox(height: 12),
          
          // Order Status
          DetailRow(
            label: AppLocalizations.of(context).status,
            value: _getLocalizedStatus(context, orderDetails.status),
            valueColor: StatusColors.getTextColor(orderDetails.status),
          ),
        ],
      ),
    );
  }

  String _getLocalizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    switch (status.toLowerCase()) {
      case 'new':
        return l10n.newStatus;
      case 'picked up':
        return l10n.pickedUpStatus;
      case 'in stock':
        return l10n.inStockStatus;
      case 'in progress':
        return l10n.inProgressStatus;
      case 'heading to customer':
        return l10n.headingToCustomerStatus;
      case 'heading to you':
        return l10n.headingToYouStatus;
      case 'completed':
        return l10n.completedStatus;
      case 'canceled':
      case 'cancelled':
        return l10n.canceledStatus;
      case 'rejected':
        return l10n.rejectedStatus;
      case 'returned':
        return l10n.returnedStatus;
      case 'terminated':
        return l10n.terminatedStatus;
      default:
        return status;
    }
  }
}