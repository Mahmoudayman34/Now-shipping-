import 'package:flutter/material.dart';
import 'package:now_shipping/core/constants/order_constants.dart';

/// Utility class for order status colors based on the new order structure
class StatusColors {
  /// Background colors for different order statuses (display names)
  static const Map<String, Color> statusBackgroundColors = {
    // NEW Category - Blue
    'New': Color(0xFFCFE2FF),
    'Pending Pickup': Color(0xFFCFE2FF),
    
    // PROCESSING Category - Yellow/Cyan/Gray
    'Picked Up': Color(0xFFE2E3E5),
    'In Stock': Color(0xFFCFF4FC),
    'In Return Stock': Color(0xFFCFF4FC),
    'In Progress': Color(0xFFFFF3CD),
    'Heading to Customer': Color(0xFFD1E7DD),
    'Return to Warehouse': Color(0xFFCFF4FC),
    'Heading to You': Color(0xFFD1E7DD),
    'Rescheduled': Color(0xFFFFF3CD),
    'Return Initiated': Color(0xFFFFF3CD),
    'Return Assigned': Color(0xFFE2E3E5),
    'Return Picked Up': Color(0xFFE2E3E5),
    'Return at Warehouse': Color(0xFFCFF4FC),
    'Return to Business': Color(0xFFD1E7DD),
    'Return Linked': Color(0xFFE2E3E5),
    
    // PAUSED Category - Cyan
    'Waiting Action': Color(0xFFCFF4FC),
    'Rejected': Color(0xFFF8D7DA),
    
    // SUCCESSFUL Category - Green
    'Completed': Color(0xFFD1E7DD),
    'Return Completed': Color(0xFFD1E7DD),
    'Successful': Color(0xFFD1E7DD),
    
    // UNSUCCESSFUL Category - Red
    'Canceled': Color(0xFFF8D7DA),
    'Returned': Color(0xFFF8D7DA),
    'Terminated': Color(0xFFF8D7DA),
    'Delivery Failed': Color(0xFFF8D7DA),
    'Auto Return Initiated': Color(0xFFF8D7DA),
    'Unsuccessful': Color(0xFFF8D7DA),
    'Rejected Returns': Color(0xFFF8D7DA),
    
    // Legacy support
    'Picked up': Color(0xFFE2E3E5),
    'Heading to customer': Color(0xFFD1E7DD),
    'Heading to you': Color(0xFFD1E7DD),
    'Awaiting Action': Color(0xFFCFF4FC),
    'Heading': Color(0xFFD1E7DD),
  };

  /// Text colors for different order statuses (display names)
  static const Map<String, Color> statusTextColors = {
    // NEW Category - Blue
    'New': Color(0xFF084298),
    'Pending Pickup': Color(0xFF084298),
    
    // PROCESSING Category
    'Picked Up': Color(0xFF41464B),
    'In Stock': Color(0xFF055160),
    'In Return Stock': Color(0xFF055160),
    'In Progress': Color(0xFF664D03),
    'Heading to Customer': Color(0xFF0F5132),
    'Return to Warehouse': Color(0xFF055160),
    'Heading to You': Color(0xFF0F5132),
    'Rescheduled': Color(0xFF664D03),
    'Return Initiated': Color(0xFF664D03),
    'Return Assigned': Color(0xFF41464B),
    'Return Picked Up': Color(0xFF41464B),
    'Return at Warehouse': Color(0xFF055160),
    'Return to Business': Color(0xFF0F5132),
    'Return Linked': Color(0xFF41464B),
    
    // PAUSED Category
    'Waiting Action': Color(0xFF055160),
    'Rejected': Color(0xFF842029),
    
    // SUCCESSFUL Category - Green
    'Completed': Color(0xFF0F5132),
    'Return Completed': Color(0xFF0F5132),
    'Successful': Color(0xFF0F5132),
    
    // UNSUCCESSFUL Category - Red
    'Canceled': Color(0xFF842029),
    'Returned': Color(0xFF842029),
    'Terminated': Color(0xFF842029),
    'Delivery Failed': Color(0xFF842029),
    'Auto Return Initiated': Color(0xFF842029),
    'Unsuccessful': Color(0xFF842029),
    'Rejected Returns': Color(0xFF842029),
    
    // Legacy support
    'Picked up': Color(0xFF41464B),
    'Heading to customer': Color(0xFF0F5132),
    'Heading to you': Color(0xFF0F5132),
    'Awaiting Action': Color(0xFF055160),
    'Heading': Color(0xFF0F5132),
  };

  /// Category-based colors
  static const Map<OrderStatusCategory, Color> categoryBackgroundColors = {
    OrderStatusCategory.newOrder: Color(0xFFCFE2FF),
    OrderStatusCategory.processing: Color(0xFFFFF3CD),
    OrderStatusCategory.paused: Color(0xFFCFF4FC),
    OrderStatusCategory.successful: Color(0xFFD1E7DD),
    OrderStatusCategory.unsuccessful: Color(0xFFF8D7DA),
  };

  static const Map<OrderStatusCategory, Color> categoryTextColors = {
    OrderStatusCategory.newOrder: Color(0xFF084298),
    OrderStatusCategory.processing: Color(0xFF664D03),
    OrderStatusCategory.paused: Color(0xFF055160),
    OrderStatusCategory.successful: Color(0xFF0F5132),
    OrderStatusCategory.unsuccessful: Color(0xFF842029),
  };

  /// Get background color for a status
  static Color getBackgroundColor(String status) {
    return statusBackgroundColors[status] ?? const Color(0xFFE2E3E5);
  }

  /// Get text color for a status
  static Color getTextColor(String status) {
    return statusTextColors[status] ?? const Color(0xFF41464B);
  }

  /// Get background color by category
  static Color getCategoryBackgroundColor(OrderStatusCategory category) {
    return categoryBackgroundColors[category] ?? const Color(0xFFE2E3E5);
  }

  /// Get text color by category
  static Color getCategoryTextColor(OrderStatusCategory category) {
    return categoryTextColors[category] ?? const Color(0xFF41464B);
  }

  /// Get background color from status string (handles both display and API status)
  static Color getBackgroundColorFromStatus(String status) {
    // Try with display name first
    final displayName = OrderStatus.getDisplayName(status);
    if (statusBackgroundColors.containsKey(displayName)) {
      return statusBackgroundColors[displayName]!;
    }
    
    // Fall back to category-based color
    final category = OrderStatus.getCategory(status);
    return getCategoryBackgroundColor(category);
  }

  /// Get text color from status string (handles both display and API status)
  static Color getTextColorFromStatus(String status) {
    // Try with display name first
    final displayName = OrderStatus.getDisplayName(status);
    if (statusTextColors.containsKey(displayName)) {
      return statusTextColors[displayName]!;
    }
    
    // Fall back to category-based color
    final category = OrderStatus.getCategory(status);
    return getCategoryTextColor(category);
  }
}