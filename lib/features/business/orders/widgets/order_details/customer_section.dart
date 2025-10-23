import 'package:flutter/material.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/section_utilities.dart';
import '../../../../../core/l10n/app_localizations.dart';

class CustomerSection extends StatelessWidget {
  final OrderDetailsModel orderDetails;

  const CustomerSection({
    super.key,
    required this.orderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: AppLocalizations.of(context).customer, icon: Icons.person_outline),
          const SizedBox(height: 16),
          
          // Customer name
          Text(
            orderDetails.customerName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F2F2F),
            ),
          ),
          const SizedBox(height: 8),
          
          // Phone
          Row(
            children: [
              Icon(Icons.phone_rounded, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 10),
              Text(
                orderDetails.customerPhone,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_rounded, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  orderDetails.customerAddress,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    letterSpacing: 0.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}