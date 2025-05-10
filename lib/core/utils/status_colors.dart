import 'package:flutter/material.dart';

/// Utility class for order status colors
class StatusColors {
  /// Background colors for different order statuses
  static const Map<String, Color> statusBackgroundColors = {
    'New': Color(0xFFCFE2FF),
    'Picked up': Color(0xFFE2E3E5),
    'In Stock': Color(0xFFCFF4FC),
    'In Progress': Color(0xFFFFF3CD),
    'Heading to customer': Color(0xFFD1E7DD),
    'Heading to you': Color(0xFFD1E7DD),
    'Completed': Color(0xFFD1E7DD),
    'Successful': Color(0xFFD1E7DD), // Same as completed
    'Canceled': Color(0xFFF8D7DA),
    'Rejected': Color(0xFFF8D7DA),
    'Returned': Color(0xFFF8D7DA),
    'Terminated': Color(0xFFF8D7DA),
    'Awaiting Action': Color(0xFFCFF4FC), // Similar to In Stock
    'Heading': Color(0xFFD1E7DD), // Same as Heading to customer
    'Unsuccessful': Color(0xFFF8D7DA), // Similar to Canceled
    'Rejected Returns': Color(0xFFF8D7DA), // Similar to Rejected
  };

  /// Text colors for different order statuses
  static const Map<String, Color> statusTextColors = {
    'New': Color(0xFF084298),
    'Picked up': Color(0xFF41464B),
    'In Stock': Color(0xFF055160),
    'In Progress': Color(0xFF664D03),
    'Heading to customer': Color(0xFF0F5132),
    'Heading to you': Color(0xFF0F5132),
    'Completed': Color(0xFF0F5132),
    'Successful': Color(0xFF0F5132), // Same as completed
    'Canceled': Color(0xFF842029),
    'Rejected': Color(0xFF842029),
    'Returned': Color(0xFF842029),
    'Terminated': Color(0xFF842029),
    'Awaiting Action': Color(0xFF055160), // Similar to In Stock
    'Heading': Color(0xFF0F5132), // Same as Heading to customer
    'Unsuccessful': Color(0xFF842029), // Similar to Canceled
    'Rejected Returns': Color(0xFF842029), // Similar to Rejected
  };

  /// Get background color for a status
  static Color getBackgroundColor(String status) {
    return statusBackgroundColors[status] ?? const Color(0xFFE2E3E5);
  }

  /// Get text color for a status
  static Color getTextColor(String status) {
    return statusTextColors[status] ?? const Color(0xFF41464B);
  }
}