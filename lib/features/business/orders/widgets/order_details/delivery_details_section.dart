import 'package:flutter/material.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/section_utilities.dart';
import '../../../../../core/l10n/app_localizations.dart';

class DeliveryDetailsSection extends StatelessWidget {
  final OrderDetailsModel orderDetails;

  const DeliveryDetailsSection({
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
            title: AppLocalizations.of(context).deliveryDetails,
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 16),
          
          // Package Type
          DetailRow(
            label: AppLocalizations.of(context).packageType,
            value: _getLocalizedPackageType(context, orderDetails.packageType),
          ),
          
          const SizedBox(height: 12),
          
          // Number of Items
          DetailRow(
            label: AppLocalizations.of(context).numberOfItems,
            value: '${orderDetails.numberOfItems}',
          ),
          
          const SizedBox(height: 12),
          
          // Package Description
          DetailRow(
            label: AppLocalizations.of(context).packageDescription,
            value: orderDetails.packageDescription,
            maxLines: 3,
          ),
          
          const SizedBox(height: 12),
          
          // Cash on Delivery
          DetailRow(
            label: AppLocalizations.of(context).cashOnDeliveryText,
            value: '${orderDetails.collectCashAmount} EGP',
            isHighlighted: true,
          ),
          
          const SizedBox(height: 12),
          
          // Allow Opening Package
          Row(
            children: [
              Icon(
                orderDetails.allowOpeningPackage
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: const Color(0xFFFF6B35),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context).allowCustomerInspect,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Express Shipping
          Row(
            children: [
              Icon(
                orderDetails.isExpressShipping
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: const Color(0xFFFF6B35),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context).expressShipping,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLocalizedPackageType(BuildContext context, String packageType) {
    final l10n = AppLocalizations.of(context);
    switch (packageType.toLowerCase()) {
      case 'parcel':
        return l10n.parcel;
      default:
        return packageType;
    }
  }
}