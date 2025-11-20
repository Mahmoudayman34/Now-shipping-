import 'package:flutter/material.dart';
import 'package:now_shipping/core/utils/responsive_utils.dart';
import 'package:now_shipping/core/l10n/app_localizations.dart';

/// Professional tracking step item with orange and white theme (Responsive)
class TrackingStepItem extends StatelessWidget {
  final bool isCompleted;
  final String title;
  final String status;
  final String description;
  final String time;
  final bool isFirst;
  final bool isLast;

  const TrackingStepItem({
    super.key,
    required this.isCompleted,
    required this.title,
    required this.status,
    required this.description,
    required this.time,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    // Professional orange and white color scheme
    const Color primaryOrange = Color(0xFFFF6B35);
    const Color lightOrange = Color(0xFFFFB499);
    const Color darkOrange = Color(0xFFE55A2B);
    final Color cardBackground = Colors.grey.shade50;
    final Color incompleteColor = Colors.grey.shade300;
    
    // Responsive sizes
    final screenType = ResponsiveUtils.getScreenType(context);
    final double circleSize = screenType == ScreenType.mobile ? 40 : 
                              screenType == ScreenType.tablet ? 48 : 56;
    final double checkIconSize = screenType == ScreenType.mobile ? 22 : 
                                 screenType == ScreenType.tablet ? 28 : 32;
    final double lineThickness = screenType == ScreenType.mobile ? 3 : 4;
    final double lineHeight = screenType == ScreenType.mobile ? 70 : 80;
    final double horizontalSpacing = screenType == ScreenType.mobile ? 16 : 20;
    final double cardPadding = screenType == ScreenType.mobile ? 14 : 16;
    final double borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    final double titleSize = ResponsiveUtils.getResponsiveFontSize(
      context, 
      mobile: 16, 
      tablet: 17, 
      desktop: 18,
    );
    final double descSize = ResponsiveUtils.getResponsiveFontSize(
      context, 
      mobile: 13, 
      tablet: 14, 
      desktop: 15,
    );
    final double timeSize = ResponsiveUtils.getResponsiveFontSize(
      context, 
      mobile: 12, 
      tablet: 13, 
      desktop: 14,
    );
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          Column(
            children: [
              // Circle indicator
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isCompleted
                      ? const LinearGradient(
                          colors: [primaryOrange, darkOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isCompleted ? null : Colors.white,
                  border: Border.all(
                    color: isCompleted ? primaryOrange : incompleteColor,
                    width: lineThickness,
                  ),
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: primaryOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: checkIconSize,
                      )
                    : Center(
                        child: Container(
                          width: circleSize * 0.25,
                          height: circleSize * 0.25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: incompleteColor,
                          ),
                        ),
                      ),
              ),
              // Connecting line
              if (!isLast)
                Container(
                  width: lineThickness,
                  height: lineHeight,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? const LinearGradient(
                            colors: [primaryOrange, lightOrange],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: isCompleted ? null : incompleteColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
          SizedBox(width: horizontalSpacing),
          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.white : cardBackground,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: isCompleted ? primaryOrange.withOpacity(0.3) : incompleteColor,
                  width: 1.5,
                ),
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: primaryOrange.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? const Color(0xFF2C3E50) : Colors.grey.shade600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      if (isCompleted && isLast)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenType == ScreenType.mobile ? 8 : 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [primaryOrange, darkOrange],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppLocalizations.of(context).currentStatus,
                            style: TextStyle(
                              fontSize: screenType == ScreenType.mobile ? 10 : 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: descSize,
                      color: isCompleted ? Colors.grey.shade700 : Colors.grey.shade500,
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                  // Time stamp
                  if (time.isNotEmpty) ...[
                    SizedBox(height: screenType == ScreenType.mobile ? 10 : 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: screenType == ScreenType.mobile ? 14 : 16,
                          color: isCompleted ? primaryOrange : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: timeSize,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? primaryOrange : Colors.grey.shade400,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}