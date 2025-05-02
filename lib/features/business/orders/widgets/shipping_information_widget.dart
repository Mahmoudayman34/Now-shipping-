import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/features/business/orders/providers/order_providers.dart';

class ShippingInformationWidget extends ConsumerWidget {
  final bool isEditing;
  
  const ShippingInformationWidget({
    Key? key,
    this.isEditing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderModelProvider);
    final selectedDeliveryType = order.deliveryType ?? 'Deliver';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Shipping Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Select delivery type and provide shipping details',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Order Type text heading
          const Text(
            'Order Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Shipping cards grid
          Row(
            children: [
              // Deliver Card
              Expanded(
                child: _buildShippingTypeCard(
                  type: 'Deliver',
                  icon: Icons.local_shipping,
                  isSelected: selectedDeliveryType == 'Deliver',
                  iconColor: Colors.orange.shade300,
                  onTap: isEditing ? null : () => _updateDeliveryType(ref, 'Deliver'),
                ),
              ),
              const SizedBox(width: 8),
              
              // Exchange Card
              Expanded(
                child: _buildShippingTypeCard(
                  type: 'Exchange',
                  icon: Icons.swap_horiz,
                  isSelected: selectedDeliveryType == 'Exchange',
                  iconColor: Colors.orange.shade300,
                  onTap: isEditing ? null : () => _updateDeliveryType(ref, 'Exchange'),
                ),
              ),
              const SizedBox(width: 8),
              
              // Return Card
              Expanded(
                child: _buildShippingTypeCard(
                  type: 'Return',
                  icon: Image.asset('assets/icons/Return.png', width: 24, height: 24,
                  color: Colors.orange.shade300),
                  isSelected: selectedDeliveryType == 'Return',
                  iconColor: Colors.orange.shade300,
                  onTap: isEditing ? null : () => _updateDeliveryType(ref, 'Return'),
                ),
              ),
              const SizedBox(width: 8),
              
              // Cash Collection Card
              Expanded(
                child: _buildShippingTypeCard(
                  type: 'Cash Collect',
                  icon: Image.asset('assets/icons/Cash.png', width: 24, height: 24,
                  color: Colors.orange.shade300),
                  isSelected: selectedDeliveryType == 'Cash Collect',
                  iconColor: Colors.orange.shade300,
                  onTap: isEditing ? null : () => _updateDeliveryType(ref, 'Cash Collect'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _updateDeliveryType(WidgetRef ref, String type) {
    ref.read(orderModelProvider.notifier).updateDeliveryType(type);
  }
  
  Widget _buildShippingTypeCard({
    required String type,
    required dynamic icon,
    required bool isSelected,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    // Add opacity to show card is disabled when in edit mode
    final bool isDisabled = onTap == null;
    
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled && !isSelected ? 0.5 : 1.0,  // Non-selected cards are dimmed in edit mode
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          width: 85, // Fixed width for all cards
          height: 102, // Fixed height for all cards
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.orange.shade300 : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon is IconData
                ? Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  )
                : icon, // Directly use the widget if it's not an IconData
              const SizedBox(height: 8),
              Text(
                type,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected? FontWeight.w600 : FontWeight.normal,
                  color: const Color(0xff2F2F2F),
                ),
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}