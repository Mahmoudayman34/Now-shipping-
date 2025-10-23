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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B35).withOpacity(0.1),
                  const Color(0xFFFFB499).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF6B35).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  deliveryType == 'Deliver' ? Icons.local_shipping_outlined :
                  deliveryType == 'Exchange' ? Icons.swap_horiz_outlined :
                  Icons.assignment_return_outlined,
                  color: const Color(0xFFFF6B35),
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLocalizedDeliveryType(context, deliveryType),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFFF6B35),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLocalizedDescription(context, deliveryType),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
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