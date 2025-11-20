import 'package:flutter/material.dart';
import 'package:now_shipping/core/l10n/app_localizations.dart';
import 'package:now_shipping/core/constants/order_constants.dart';

/// Helper class for order status localization and utilities
class OrderStatusHelper {
  /// Get localized status string based on the status and context
  static String getLocalizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);

    // Normalize incoming status: remove spaces/underscores and lowercase
    final normalized = status.replaceAll(' ', '').replaceAll('_', '').toLowerCase();

    // Debug: Print the actual status being passed
    print('DEBUG OrderStatusHelper: Received status: "$status" -> normalized: "$normalized"');

    // Match on normalized form only
    switch (normalized) {
      // NEW Category
      case 'new':
        return l10n.newStatus;
      case 'pendingpickup':
        return l10n.pendingPickup;
      
      // PROCESSING Category
      case 'pickedup':
        return l10n.pickedUpStatus;
      case 'instock':
        return l10n.inStockStatus;
      case 'inreturnstock':
        return l10n.inReturnStock;
      case 'inprogress':
        return l10n.inProgressStatus;
      case 'headingtocustomer':
        return l10n.headingToCustomerStatus;
      case 'returntowarehouse':
        return l10n.returnToWarehouse;
      case 'headingtoyou':
        return l10n.headingToYouStatus;
      case 'rescheduled':
        return l10n.rescheduled;
      case 'returninitiated':
        return l10n.returnInitiated;
      case 'returnassigned':
        return l10n.returnAssigned;
      case 'returnpickedup':
        return l10n.returnPickedUp;
      case 'returnatwarehouse':
        return l10n.returnAtWarehouse;
      case 'returntobusiness':
        return l10n.returnToBusiness;
      case 'returnlinked':
        return l10n.returnLinked;
      
      // PAUSED Category
      case 'waitingaction':
        return l10n.waitingAction;
      case 'rejected':
        return l10n.rejectedStatus;
      
      // SUCCESSFUL Category
      case 'completed':
        return l10n.completedStatus;
      case 'returncompleted':
        return l10n.returnCompleted;
      
      // UNSUCCESSFUL Category
      case 'canceled':
      case 'cancelled':
        return l10n.canceledStatus;
      case 'returned':
        return l10n.returnedStatus;
      case 'terminated':
        return l10n.terminatedStatus;
      case 'deliveryfailed':
        return l10n.deliveryFailed;
      case 'autoreturninitiated':
        return l10n.autoReturnInitiated;
      
      // Handle status category keys
      case 'successfulStatus':
      case 'successfulstatus':
        return l10n.successfulStatus;
      case 'processingStatus':
      case 'processingstatus':
        return l10n.processingStatus;
      case 'pausedStatus':
      case 'pausedstatus':
        return l10n.pausedStatus;
      case 'unsuccessfulStatus':
      case 'unsuccessfulstatus':
        return l10n.unsuccessfulStatus;
      
      // Legacy/Unknown
      default:
        // Try to find a translation key that matches the status
        final statusKey = normalized;
        if (statusKey.contains('successful')) {
          return l10n.successfulStatus;
        } else if (statusKey.contains('processing')) {
          return l10n.processingStatus;
        } else if (statusKey.contains('paused')) {
          return l10n.pausedStatus;
        } else if (statusKey.contains('unsuccessful')) {
          return l10n.unsuccessfulStatus;
        } else if (statusKey.contains('pending') && statusKey.contains('pickup')) {
          return l10n.pendingPickup;
        } else if (statusKey.contains('return') && statusKey.contains('warehouse')) {
          return l10n.returnToWarehouse;
        } else if (statusKey.contains('return') && statusKey.contains('completed')) {
          return l10n.returnCompleted;
        } else if (statusKey.contains('delivery') && statusKey.contains('failed')) {
          return l10n.deliveryFailed;
        } else if (statusKey.contains('auto') && statusKey.contains('return')) {
          return l10n.autoReturnInitiated;
        }
        
        print('DEBUG OrderStatusHelper: No translation found for status: "$status"');
        return OrderStatus.getDisplayName(status);
    }
  }

  static String? getLocalizedStatusDescription(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    final normalized = status.replaceAll(' ', '').replaceAll('_', '').toLowerCase();

    switch (normalized) {
      case 'pickedup':
        return l10n.pickedUpDescription;
      case 'instock':
        return l10n.inStockDescription;
      case 'headingtocustomer':
        return l10n.headingToCustomerDescription;
      case 'completed':
        return l10n.successfulDescription;
      default:
        return null;
    }
  }

  /// Get status category display name
  static String getCategoryDisplayName(BuildContext context, OrderStatusCategory category) {
    final l10n = AppLocalizations.of(context);
    
    switch (category) {
      case OrderStatusCategory.newOrder:
        return l10n.newStatus;
      case OrderStatusCategory.processing:
        return l10n.processingStatus;
      case OrderStatusCategory.paused:
        return l10n.pausedStatus;
      case OrderStatusCategory.successful:
        return l10n.successfulStatus;
      case OrderStatusCategory.unsuccessful:
        return l10n.unsuccessfulStatus;
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

