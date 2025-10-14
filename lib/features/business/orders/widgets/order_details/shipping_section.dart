import 'package:flutter/material.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/section_utilities.dart';
import '../../../../../core/l10n/app_localizations.dart';

class ShippingSection extends StatelessWidget {
  final String deliveryType;

  const ShippingSection({
    super.key,
    required this.deliveryType,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: AppLocalizations.of(context).shippingInformation,
            icon: Icons.local_shipping_outlined,
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F8FC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  deliveryType == 'Deliver' ? Icons.local_shipping_outlined :
                  deliveryType == 'Exchange' ? Icons.swap_horiz_outlined :
                  Icons.assignment_return_outlined,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedDeliveryType(context, deliveryType),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      _getLocalizedDescription(context, deliveryType),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedDeliveryType(BuildContext context, String deliveryType) {
    switch (deliveryType) {
      case 'Deliver':
        return AppLocalizations.of(context).deliverType;
      case 'Exchange':
        return AppLocalizations.of(context).exchangeType;
      case 'Return':
        return AppLocalizations.of(context).returnType;
      default:
        return deliveryType;
    }
  }

  String _getLocalizedDescription(BuildContext context, String deliveryType) {
    switch (deliveryType) {
      case 'Deliver':
        return AppLocalizations.of(context).deliverItemsToCustomer;
      case 'Exchange':
        return AppLocalizations.of(context).exchangeItemsWithCustomer;
      case 'Return':
        return AppLocalizations.of(context).returnItemsFromCustomer;
      default:
        return deliveryType;
    }
  }
}