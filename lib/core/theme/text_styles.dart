import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTypography provides a complete professional typography system for your app.
/// It uses a combination of font weights and sizes to create a consistent 
/// typographic hierarchy throughout the app.
class AppTypography {
  // Font families
  static String get primaryFontFamily => 'Poppins';
  static String get secondaryFontFamily => 'Montserrat';

  // Base text style with the primary font
  static TextStyle _baseTextStyle({String? fontFamily}) => TextStyle(
    fontFamily: GoogleFonts.getFont(fontFamily ?? primaryFontFamily).fontFamily,
    letterSpacing: 0.1,
    height: 1.5, // Better line height for readability
  );

  // Display styles (large, attention-grabbing text)
  static TextStyle displayLarge(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle displayMedium(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.2,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle displaySmall(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  // Headline styles (section headings)
  static TextStyle headlineLarge(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle headlineMedium(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle headlineSmall(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  // Title styles (component headings)
  static TextStyle titleLarge(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.4,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle titleMedium(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.4,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle titleSmall(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  // Body styles (paragraph text)
  static TextStyle bodyLarge(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
    color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
  );

  static TextStyle bodyMedium(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.5,
    color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
  );

  static TextStyle bodySmall(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.5,
    color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
  );

  // Label styles (buttons, form fields, etc.)
  static TextStyle labelLarge(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: color ?? Theme.of(context).colorScheme.primary,
  );

  static TextStyle labelMedium(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
    color: color ?? Theme.of(context).colorScheme.primary,
  );

  static TextStyle labelSmall(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
    color: color ?? Theme.of(context).colorScheme.primary,
  );

  // Specialized styles
  static TextStyle buttonText(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.75,
    height: 1.4,
    color: color ?? Colors.white,
  );

  static TextStyle caption(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.4,
    color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
  );

  static TextStyle overline(BuildContext context, {Color? color, String? fontFamily}) => _baseTextStyle(fontFamily: fontFamily).copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.4,
    color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    textBaseline: TextBaseline.alphabetic,
  );
}

// For backward compatibility with existing code
@Deprecated('Use AppTypography instead')
class TextStyles {
  static TextStyle headline1(BuildContext context) => AppTypography.displayLarge(context);
  static TextStyle headline2(BuildContext context) => AppTypography.displayMedium(context);
  static TextStyle headline3(BuildContext context) => AppTypography.displaySmall(context);
  static TextStyle subtitle1(BuildContext context) => AppTypography.titleLarge(context);
  static TextStyle subtitle2(BuildContext context) => AppTypography.titleMedium(context);
  static TextStyle bodyText1(BuildContext context) => AppTypography.bodyLarge(context);
  static TextStyle bodyText2(BuildContext context) => AppTypography.bodyMedium(context);
  static TextStyle caption(BuildContext context) => AppTypography.caption(context);
  static TextStyle button(BuildContext context) => AppTypography.buttonText(context);
}
