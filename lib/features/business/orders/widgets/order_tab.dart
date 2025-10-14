import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class OrderTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const OrderTab({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final screenType = ResponsiveUtils.getScreenType(context);
    
    // Adjust padding based on screen type for better touch targets
    final horizontalPadding = screenType == ScreenType.mobile 
        ? spacing * 1.5  // More padding on mobile
        : screenType == ScreenType.tablet 
            ? spacing * 1.2  // Reduced padding on tablet
            : spacing * 1.0;  // Standard padding on desktop
    
    final verticalPadding = screenType == ScreenType.mobile 
        ? spacing * 0.9  // More vertical padding on mobile
        : screenType == ScreenType.tablet 
            ? spacing * 0.8  // Reduced vertical padding on tablet
            : spacing * 0.6;  // Standard vertical padding on desktop
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(right: spacing * 1.0),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, 
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 1.2),
            border: Border.all(
              color: isSelected ? Colors.blue.shade300 : const Color(0xff8cc3d8),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue.shade800 : const Color(0xff2F2F2F),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 13, 
                tablet: 14, 
                desktop: 16,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}