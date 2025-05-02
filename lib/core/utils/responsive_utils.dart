import 'package:flutter/material.dart';

/// Utility class for responsive design
class ResponsiveUtils {
  /// Maximum width for content on large screens
  static const double maxContentWidth = 900.0;
  
  /// Returns a widget that centers its child and constrains its width
  /// to ensure better display on larger screens
  static Widget wrapWithMaxWidth(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: maxContentWidth,
        ),
        child: child,
      ),
    );
  }
  
  /// Wraps a screen with max width constraint and preserves Scaffold elements
  static Widget wrapScreen({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    Color? backgroundColor,
    bool? resizeToAvoidBottomInset,
  }) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: wrapWithMaxWidth(body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}