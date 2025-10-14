import 'package:flutter/material.dart';
import 'package:now_shipping/core/utils/status_colors.dart';
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
    required this.onTap,
  });

  // Function to make a phone call
  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch $phoneUri');
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
                      Container(
                        constraints: BoxConstraints(
                          minWidth: ResponsiveUtils.getResponsiveSpacing(context) * 4,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing * 1.0, 
                          vertical: spacing * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: StatusColors.getBackgroundColor(status),
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5),
                        ),
                        child: Text(
                          _getLocalizedStatus(context, status),
                          style: TextStyle(
                            color: StatusColors.getTextColor(status),
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
                    ],
                  ),
                  SizedBox(height: spacing * 0.3),
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
    final l10n = AppLocalizations.of(context);
    switch (orderType) {
      case 'Deliver':
        return l10n.deliverType;
      case 'Exchange':
        return l10n.exchangeType;
      case 'Return':
        return l10n.returnType;
      case 'Cash Collection':
        return l10n.cashCollectionType;
      default:
        return orderType;
    }
  }

  String _getLocalizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case 'New':
        return l10n.newStatus;
      case 'Picked Up':
        return l10n.pickedUpStatus;
      case 'In Stock':
        return l10n.inStockStatus;
      case 'In Progress':
        return l10n.inProgressStatus;
      case 'Heading To Customer':
        return l10n.headingToCustomerStatus;
      case 'Heading To You':
        return l10n.headingToYouStatus;
      case 'Completed':
        return l10n.completedStatus;
      case 'Canceled':
        return l10n.canceledStatus;
      case 'Rejected':
        return l10n.rejectedStatus;
      case 'Returned':
        return l10n.returnedStatus;
      case 'Terminated':
        return l10n.terminatedStatus;
      default:
        return status;
    }
  }
}