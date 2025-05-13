import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isRead ? Colors.grey.shade100 : const Color(0xfff29620).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications,
            color: isRead ? Colors.grey : const Color(0xfff29620),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
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