import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 18, 
                tablet: 20, 
                desktop: 22,
              ),
            ),
          ),
        ),
        body: ListView.builder(
          padding: ResponsiveUtils.getResponsivePadding(context),
        itemCount: _demoNotifications.length,
        itemBuilder: (context, index) {
          final notification = _demoNotifications[index];
          return _buildNotificationCard(
            context,
            title: notification['title'],
            message: notification['message'],
            time: notification['time'],
            isRead: notification['isRead'],
          );
        },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context);
    
    return Card(
      margin: EdgeInsets.only(bottom: spacing * 0.8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 1.5),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing,
          vertical: spacing * 0.8,
        ),
        leading: Container(
          width: iconSize * 2.5,
          height: iconSize * 2.5,
          decoration: BoxDecoration(
            color: isRead ? Colors.grey.shade100 : const Color(0xfff29620).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications,
            color: isRead ? Colors.grey : const Color(0xfff29620),
            size: iconSize,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context, 
              mobile: 14, 
              tablet: 16, 
              desktop: 18,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: spacing * 0.5),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context, 
                  mobile: 12, 
                  tablet: 14, 
                  desktop: 16,
                ),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing * 0.5),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context, 
                  mobile: 10, 
                  tablet: 12, 
                  desktop: 14,
                ),
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  // Demo notification data
  static final List<Map<String, dynamic>> _demoNotifications = [
    {
      'title': 'Order Delivered',
      'message': 'Your order #12345 has been successfully delivered.',
      'time': '10 minutes ago',
      'isRead': false,
    },
    {
      'title': 'New Promo Available',
      'message': 'Get 15% off on your next shipment with code SHIP15.',
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'title': 'Payment Success',
      'message': 'Payment for order #12340 was successful.',
      'time': '1 day ago',
      'isRead': true,
    },
    {
      'title': 'System Maintenance',
      'message': 'We will be performing maintenance on June 15th from 2-4 AM.',
      'time': '2 days ago',
      'isRead': true,
    },
  ];
} 