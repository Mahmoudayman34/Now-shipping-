import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class SpecialRequirementCard extends StatelessWidget {
  const SpecialRequirementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(spacing),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? Colors.orange.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon at the top
            Icon(
              icon,
              size: iconSize * 1.4,
              color: isSelected ? Colors.orange.shade300 : Colors.grey.shade400,
            ),
            SizedBox(height: spacing),

            // Title in the middle
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xff2F2F2F),
              ),
            ),
            SizedBox(height: spacing * 0.67),

            // Subtitle at the bottom
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
                color: Colors.grey.shade500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}