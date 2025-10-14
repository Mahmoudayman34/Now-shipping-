import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_utils.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      textTheme: GoogleFonts.interTextTheme(
        Theme.of(context).textTheme,
      ).copyWith(
        // Responsive text themes
        headlineLarge: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 24,
            tablet: 28,
            desktop: 32,
          ),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          ),
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 18,
            tablet: 22,
            desktop: 26,
          ),
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 10,
            tablet: 12,
            desktop: 14,
          ),
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff2F2F2F),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff2F2F2F)),
        titleTextStyle: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 18,
            tablet: 20,
            desktop: 22,
          ),
          fontWeight: FontWeight.w600,
          color: const Color(0xff2F2F2F),
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      // Responsive card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context),
          ),
        ),
        margin: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context) / 2,
        ),
      ),
      // Responsive button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveSpacing(context),
            vertical: ResponsiveUtils.getResponsiveSpacing(context) / 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Responsive text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveSpacing(context) / 2,
            vertical: ResponsiveUtils.getResponsiveSpacing(context) / 4,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(
        Theme.of(context).textTheme,
      ).copyWith(
        // Responsive dark text themes
        headlineLarge: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 24,
            tablet: 28,
            desktop: 32,
          ),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          ),
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 18,
            tablet: 22,
            desktop: 26,
          ),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 18,
            tablet: 20,
            desktop: 22,
          ),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      // Responsive card theme for dark mode
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context),
          ),
        ),
        margin: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context) / 2,
        ),
      ),
    );
  }
}
