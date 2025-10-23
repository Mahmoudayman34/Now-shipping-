import 'package:flutter/material.dart';
import 'package:now_shipping/core/l10n/app_localizations.dart';
import 'package:now_shipping/core/constants/order_constants.dart';

/// Helper class for order status localization and utilities
class OrderStatusHelper {
  /// Get localized status string based on the status and context
  static String getLocalizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    
    // Normalize status for comparison
    final normalizedStatus = status.toLowerCase().replaceAll(' ', '');
    
    switch (normalizedStatus) {
      // NEW Category
      case 'new':
        return l10n.newStatus;
      case 'pendingpickup':
        return 'Pending Pickup'; // Add to localization if needed
      
      // PROCESSING Category
      case 'pickedup':
        return l10n.pickedUpStatus;
      case 'instock':
        return l10n.inStockStatus;
      case 'inreturnstock':
        return 'In Return Stock'; // Add to localization if needed
      case 'inprogress':
        return l10n.inProgressStatus;
      case 'headingtocustomer':
        return l10n.headingToCustomerStatus;
      case 'returntowarehouse':
        return 'Return to Warehouse'; // Add to localization if needed
      case 'headingtoyou':
        return l10n.headingToYouStatus;
      case 'rescheduled':
        return 'Rescheduled'; // Add to localization if needed
      case 'returninitiated':
        return 'Return Initiated'; // Add to localization if needed
      case 'returnassigned':
        return 'Return Assigned'; // Add to localization if needed
      case 'returnpickedup':
        return 'Return Picked Up'; // Add to localization if needed
      case 'returnatwarehouse':
        return 'Return at Warehouse'; // Add to localization if needed
      case 'returntobusiness':
        return 'Return to Business'; // Add to localization if needed
      case 'returnlinked':
        return 'Return Linked'; // Add to localization if needed
      
      // PAUSED Category
      case 'waitingaction':
        return 'Waiting Action'; // Add to localization if needed
      case 'rejected':
        return l10n.rejectedStatus;
      
      // SUCCESSFUL Category
      case 'completed':
        return l10n.completedStatus;
      case 'returncompleted':
        return 'Return Completed'; // Add to localization if needed
      
      // UNSUCCESSFUL Category
      case 'canceled':
      case 'cancelled':
        return l10n.canceledStatus;
      case 'returned':
        return l10n.returnedStatus;
      case 'terminated':
        return l10n.terminatedStatus;
      case 'deliveryfailed':
        return 'Delivery Failed'; // Add to localization if needed
      case 'autoreturninitiated':
        return 'Auto Return Initiated'; // Add to localization if needed
      
      // Legacy/Unknown
      default:
        return OrderStatus.getDisplayName(status);
    }
  }

  /// Get status category display name
  static String getCategoryDisplayName(OrderStatusCategory category) {
    switch (category) {
      case OrderStatusCategory.newOrder:
        return 'New';
      case OrderStatusCategory.processing:
        return 'Processing';
      case OrderStatusCategory.paused:
        return 'Paused';
      case OrderStatusCategory.successful:
        return 'Successful';
      case OrderStatusCategory.unsuccessful:
        return 'Unsuccessful';
    }
  }

  /// Get all available status tabs for filtering
  static List<String> getAvailableStatusTabs(BuildContext context) {
    return [
      'All',
      'New',
      'Pending Pickup',
      'Picked Up',
      'In Stock',
      'In Progress',
      'Heading to Customer',
      'Heading to You',
      'Completed',
      'Canceled',
      'Rejected',
      'Returned',
      'Terminated',
      'Return Initiated',
      'Return Completed',
    ];
  }

  /// Get status tabs by category
  static Map<String, List<String>> getStatusTabsByCategory() {
    return {
      'All': ['All'],
      'New': ['New', 'Pending Pickup'],
      'Processing': [
        'Picked Up',
        'In Stock',
        'In Return Stock',
        'In Progress',
        'Heading to Customer',
        'Return to Warehouse',
        'Heading to You',
        'Rescheduled',
        'Return Initiated',
        'Return Assigned',
        'Return Picked Up',
        'Return at Warehouse',
        'Return to Business',
        'Return Linked',
      ],
      'Paused': ['Waiting Action', 'Rejected'],
      'Successful': ['Completed', 'Return Completed'],
      'Unsuccessful': [
        'Canceled',
        'Returned',
        'Terminated',
        'Delivery Failed',
        'Auto Return Initiated',
      ],
    };
  }

  /// Check if status is a return-related status
  static bool isReturnStatus(String status) {
    final normalizedStatus = status.toLowerCase().replaceAll(' ', '');
    return normalizedStatus.contains('return') || 
           normalizedStatus == 'returned';
  }

  /// Get status icon based on category
  static IconData getStatusIcon(String status) {
    final category = OrderStatus.getCategory(status);
    
    switch (category) {
      case OrderStatusCategory.newOrder:
        return Icons.fiber_new_rounded;
      case OrderStatusCategory.processing:
        return Icons.sync_rounded;
      case OrderStatusCategory.paused:
        return Icons.pause_circle_outline_rounded;
      case OrderStatusCategory.successful:
        return Icons.check_circle_outline_rounded;
      case OrderStatusCategory.unsuccessful:
        return Icons.cancel_outlined;
    }
  }

  /// Get order type localized string
  static String getLocalizedOrderType(BuildContext context, String orderType) {
    final l10n = AppLocalizations.of(context);
    
    switch (orderType.toLowerCase()) {
      case 'deliver':
        return l10n.deliverType;
      case 'exchange':
        return l10n.exchangeType;
      case 'return':
        return l10n.returnType;
      case 'cash collection':
        return l10n.cashCollectionType;
      default:
        return orderType;
    }
  }
}

