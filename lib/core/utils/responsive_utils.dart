import 'package:flutter/material.dart';

/// Utility class for responsive design
class ResponsiveUtils {
  // Breakpoints for different screen sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Maximum content width for different screen sizes
  static const double mobileMaxWidth = double.infinity;
  static const double tabletMaxWidth = 800;
  static const double desktopMaxWidth = 1200;
  
  /// Maximum width for content on large screens (legacy support)
  static const double maxContentWidth = 900.0;
  
  /// Get current screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }
  
  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16);
      case ScreenType.tablet:
        return const EdgeInsets.all(24);
      case ScreenType.desktop:
        return const EdgeInsets.all(32);
    }
  }
  
  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16);
      case ScreenType.tablet:
        return const EdgeInsets.symmetric(horizontal: 24);
      case ScreenType.desktop:
        return const EdgeInsets.symmetric(horizontal: 32);
    }
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }
  
  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 2;
      case ScreenType.tablet:
        return 3;
      case ScreenType.desktop:
        return 4;
    }
  }
  
  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 12;
      case ScreenType.tablet:
        return 16;
      case ScreenType.desktop:
        return 20;
    }
  }
  
  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 20;
      case ScreenType.tablet:
        return 24;
      case ScreenType.desktop:
        return 28;
    }
  }
  
  /// Get responsive image size
  static double getResponsiveImageSize(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 40;
      case ScreenType.tablet:
        return 50;
      case ScreenType.desktop:
        return 60;
    }
  }
  
  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 8;
      case ScreenType.tablet:
        return 12;
      case ScreenType.desktop:
        return 16;
    }
  }
  
  /// Wrap content with responsive constraints
  static Widget wrapWithResponsiveConstraints(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = getScreenType(context);
        double maxWidth;
        
        switch (screenType) {
          case ScreenType.mobile:
            maxWidth = mobileMaxWidth;
            break;
          case ScreenType.tablet:
            maxWidth = tabletMaxWidth;
            break;
          case ScreenType.desktop:
            maxWidth = desktopMaxWidth;
            break;
        }
        
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
  
  /// Returns a widget that centers its child and constrains its width
  /// to ensure better display on larger screens
  static Widget wrapWithMaxWidth(Widget child) {
    return wrapWithResponsiveConstraints(child);
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
      body: wrapWithResponsiveConstraints(body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
  
  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }
  
  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }
  
  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }
}

enum ScreenType { mobile, tablet, desktop }