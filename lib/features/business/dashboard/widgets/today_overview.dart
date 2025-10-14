import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';

class TodayOverview extends StatelessWidget {
  final int inHubPackages;
  
  const TodayOverview({
    super.key,
    required this.inHubPackages,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
        final spacing = ResponsiveUtils.getResponsiveSpacing(context);
        final iconSize = ResponsiveUtils.getResponsiveIconSize(context);
        final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/calendar.png', 
                    width: iconSize, 
                    height: iconSize, 
                    color: Colors.teal,
                  ),
                  SizedBox(width: spacing / 2),
                  Text(
                    AppLocalizations.of(context).todaysOverview,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),
              Container(
                padding: EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Column(
                  children: [
                    _buildOverviewItem(
                      context,
                      AppLocalizations.of(context).youHaveInOurHubs, 
                      "$inHubPackages ${AppLocalizations.of(context).packages}",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewItem(BuildContext context, String label, String value) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context) / 4;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}