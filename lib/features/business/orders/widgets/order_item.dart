import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:now_shipping/core/utils/status_colors.dart';
import 'package:now_shipping/core/utils/order_status_helper.dart';
import 'package:now_shipping/core/constants/order_constants.dart';
import 'package:now_shipping/features/business/orders/widgets/order_actions_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';

class OrderItem extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String location;
  final String amount;
  final String status;
  final String orderType;
  final int attempts;
  final String phoneNumber;
  final String? smartFlyerBarcode;
  final VoidCallback onTap;

  const OrderItem({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.location,
    required this.amount,
    required this.status,
    required this.orderType,
    required this.attempts,
    required this.phoneNumber,
    this.smartFlyerBarcode,
    required this.onTap,
  });

  // Function to make a phone call
  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch $phoneUri');
    }
  }

  // Function to copy order number to clipboard
  Future<void> _copyOrderNumber(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: orderId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('copied to clipboard')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.grey.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final horizontalPadding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: horizontalPadding.horizontal / 2, 
              vertical: spacing * 0.7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(spacing * 1.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${_getLocalizedOrderType(context, orderType)} ',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context, 
                                    mobile: 16, 
                                    tablet: 18, 
                                    desktop: 20,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff2F2F2F),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing * 0.7, 
                                vertical: spacing * 0.3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5),
                              ),
                              child: Text(
                                '$attempts/2', 
                                style: TextStyle(
                                  color: const Color(0xff2F2F2F),
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context, 
                                    mobile: 12, 
                                    tablet: 14, 
                                    desktop: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: spacing * 0.5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Status badge
                          Container(
                            constraints: BoxConstraints(
                              minWidth: ResponsiveUtils.getResponsiveSpacing(context) * 4,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing * 1.0, 
                              vertical: spacing * 0.5,
                            ),
                            decoration: BoxDecoration(
                              color: StatusColors.getBackgroundColorFromStatus(status),
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5),
                            ),
                            child: Text(
                              OrderStatusHelper.getLocalizedStatus(context, status),
                              style: TextStyle(
                                color: StatusColors.getTextColorFromStatus(status),
                                fontWeight: FontWeight.w500,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context, 
                                  mobile: 11, 
                                  tablet: 12, 
                                  desktop: 14,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: spacing * 0.4),
                          // Category badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing * 0.8, 
                              vertical: spacing * 0.3,
                            ),
                            decoration: BoxDecoration(
                              color: StatusColors.getCategoryBackgroundColor(
                                OrderStatus.getCategory(status)
                              ).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 0.4),
                              border: Border.all(
                                color: StatusColors.getCategoryTextColor(
                                  OrderStatus.getCategory(status)
                                ).withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  OrderStatusHelper.getStatusIcon(status),
                                  size: ResponsiveUtils.getResponsiveFontSize(
                                    context,
                                    mobile: 10,
                                    tablet: 11,
                                    desktop: 12,
                                  ),
                                  color: StatusColors.getCategoryTextColor(
                                    OrderStatus.getCategory(status)
                                  ),
                                ),
                                SizedBox(width: spacing * 0.3),
                                Text(
                                  OrderStatusHelper.getCategoryDisplayName(
                                    context,
                                    OrderStatus.getCategory(status)
                                  ),
                                  style: TextStyle(
                                    color: StatusColors.getCategoryTextColor(
                                      OrderStatus.getCategory(status)
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                                      context, 
                                      mobile: 9, 
                                      tablet: 10, 
                                      desktop: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 0.3),
                  Row(
                    children: [
                      Text(
                        '${AppLocalizations.of(context).orderNumber}$orderId',
                        style: TextStyle(
                          color: const Color(0xff2F2F2F),
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context, 
                            mobile: 12, 
                            tablet: 14, 
                            desktop: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _copyOrderNumber(context),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Icon(
                            Icons.copy_rounded,
                            size: ResponsiveUtils.getResponsiveIconSize(context) * 0.6,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      // Smart Flyer Barcode Icon
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: (smartFlyerBarcode != null && smartFlyerBarcode!.isNotEmpty) 
                              ? const Color(0xFFFF9800).withOpacity(0.1)  // Orange background for assigned
                              : Colors.grey.withOpacity(0.1),             // Grey background for null
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: (smartFlyerBarcode != null && smartFlyerBarcode!.isNotEmpty) 
                                ? const Color(0xFFFF9800).withOpacity(0.3)  // Orange border for assigned
                                : Colors.grey.withOpacity(0.3),             // Grey border for null
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.qr_code,
                          size: ResponsiveUtils.getResponsiveIconSize(context) * 0.7,
                          color: (smartFlyerBarcode != null && smartFlyerBarcode!.isNotEmpty) 
                              ? const Color(0xFFFF9800)  // Orange color for assigned
                              : Colors.grey,             // Grey color for null
                        ),
                      ),
                    ],
                  ),
                  Divider(height: spacing * 1.5),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline, 
                        color: Colors.grey, 
                        size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
                      ),
                      SizedBox(width: spacing * 0.7),
                      Expanded(
                        child: Text(
                          customerName,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 
                              mobile: 14, 
                              tablet: 16, 
                              desktop: 18,
                            ),
                            color: const Color(0xff2F2F2F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(context) * 3,
                        height: ResponsiveUtils.getResponsiveSpacing(context) * 3,
                        child: ElevatedButton(
                          onPressed: _makePhoneCall,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xff2F2F2F),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 1.5),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.phone, 
                              color: const Color(0xff2F2F2F), 
                              size: ResponsiveUtils.getResponsiveIconSize(context) * 0.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 0.7),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined, 
                        color: Colors.grey, 
                        size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
                      ),
                      SizedBox(width: spacing * 0.7),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 
                              mobile: 14, 
                              tablet: 16, 
                              desktop: 18,
                            ),
                            color: const Color(0xff2F2F2F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: spacing * 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing * 0.4, 
                                vertical: spacing * 0.2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5),
                              ),
                              child: Text(
                                'EGP',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context, 
                                    mobile: 10, 
                                    tablet: 12, 
                                    desktop: 14,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            SizedBox(width: spacing * 0.3),
                            Text(
                              amount,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff2F2F2F),
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context, 
                                  mobile: 14, 
                                  tablet: 16, 
                                  desktop: 18,
                                ),
                              ),
                            ),
                            SizedBox(width: spacing * 0.7),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).cashOnDeliveryText,
                                style: TextStyle(
                                  color: const Color(0xff2F2F2F),
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context, 
                                    mobile: 12, 
                                    tablet: 14, 
                                    desktop: 16,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_horiz, 
                          color: const Color(0xff2F2F2F),
                          size: ResponsiveUtils.getResponsiveIconSize(context),
                        ),
                        onPressed: () {
                          showOrderActionsBottomSheet(context, {
                            'orderId': orderId,
                            'customerName': customerName,
                            'location': location,
                            'amount': amount,
                            'status': status,
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
  }

  String _getLocalizedOrderType(BuildContext context, String orderType) {
    return OrderStatusHelper.getLocalizedOrderType(context, orderType);
  }
}