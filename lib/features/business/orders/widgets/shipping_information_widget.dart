import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';

class ShippingInformationWidget extends ConsumerWidget {
  final bool isEditing;
  
  const ShippingInformationWidget({
    super.key,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderModelProvider);
    final selectedDeliveryType = order.deliveryType ?? 'Deliver';
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);

    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
          Text(
            AppLocalizations.of(context).shippingInformation,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
              fontWeight: FontWeight.w600,
              color: const Color(0xff2F2F2F),
            ),
          ),
          
          SizedBox(height: spacing * 0.67),
          
          // Subtitle
          Text(
            AppLocalizations.of(context).selectDeliveryTypeDescription,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
              color: Colors.grey,
            ),
          ),
          
          SizedBox(height: spacing),
          
          // Order Type text heading
          Text(
            AppLocalizations.of(context).orderType,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              fontWeight: FontWeight.w500,
              color: const Color(0xff2F2F2F),
            ),
          ),
          
          SizedBox(height: spacing),
          
          // Shipping cards grid
          Row(
            children: [
              // Deliver Card
              Expanded(
                child: _buildShippingTypeCard(
                  context,
                  type: 'Deliver',
                  icon: Icons.local_shipping,
                  isSelected: selectedDeliveryType == 'Deliver',
                  iconColor: Colors.orange.shade300,
                  onTap: isEditing ? null : () => _updateDeliveryType(ref, 'Deliver'),
                ),
              ),
              SizedBox(width: spacing * 0.67),
              
              // Exchange Card
              Expanded(
                child: _buildShippingTypeCard(
                  context,
                  type: 'Exchange',
                  icon: Icons.swap_horiz,
                  isSelected: selectedDeliveryType == 'Exchange',
                  iconColor: Colors.orange.shade300,
                  onTap: isEditing ? null : () => _updateDeliveryType(ref, 'Exchange'),
                ),
              ),
              SizedBox(width: spacing * 0.67),
              
              // Return Card
              Expanded(
                child: _buildShippingTypeCard(
                  context,
                  type: 'Return',
                  icon: Image.asset(
                    'assets/icons/Return.png',
                    width: ResponsiveUtils.getResponsiveIconSize(context),
                    height: ResponsiveUtils.getResponsiveIconSize(context),
                    color: Colors.orange.shade300,
                  ),
                  isSelected: selectedDeliveryType == 'Return',
                  iconColor: Colors.orange.shade300,
                  onTap: isEditing ? null : () => _updateDeliveryType(ref, 'Return'),
                ),
              ),
              SizedBox(width: spacing * 0.67),
              
              // Cash Collection Card
              Expanded(
                child: _buildShippingTypeCard(
                  context,
                  type: 'Cash Collect',
                  icon: Image.asset(
                    'assets/icons/Cash.png',
                    width: ResponsiveUtils.getResponsiveIconSize(context),
                    height: ResponsiveUtils.getResponsiveIconSize(context),
                    color: Colors.orange.shade300,
                  ),
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
  
  Widget _buildShippingTypeCard(BuildContext context, {
    required String type,
    required dynamic icon,
    required bool isSelected,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    // Add opacity to show card is disabled when in edit mode
    final bool isDisabled = onTap == null;
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled && !isSelected ? 0.5 : 1.0,  // Non-selected cards are dimmed in edit mode
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: spacing,
            horizontal: spacing * 0.33,
          ),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
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
                    size: iconSize,
                  )
                : icon, // Directly use the widget if it's not an IconData
              SizedBox(height: spacing * 0.67),
              Text(
                _getLocalizedShippingType(context, type),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 11,
                    tablet: 13,
                    desktop: 15,
                  ),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  String _getLocalizedShippingType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case 'Deliver':
        return l10n.deliverType;
      case 'Exchange':
        return l10n.exchangeType;
      case 'Return':
        return l10n.returnType;
      case 'Cash Collect':
        return l10n.cashCollect;
      default:
        return type;
    }
  }
}