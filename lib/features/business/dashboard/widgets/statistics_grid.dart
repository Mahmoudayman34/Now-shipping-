import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';

class StatisticsGrid extends StatelessWidget {
  final int headingToCustomer;
  final int awaitingAction;
  final int successfulOrders;
  final int unsuccessfulOrders;
  final int headingToYou;
  final int newOrders;
  final double successRate;
  final double unsuccessRate;
  
  const StatisticsGrid({
    super.key,
    required this.headingToCustomer,
    required this.awaitingAction,
    required this.successfulOrders,
    required this.unsuccessfulOrders, 
    required this.headingToYou,
    required this.newOrders,
    this.successRate = 0.0,
    this.unsuccessRate = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveUtils.getScreenType(context);
        final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
        final spacing = ResponsiveUtils.getResponsiveSpacing(context);
        final columns = ResponsiveUtils.getGridColumns(context);
        
        // Adjust aspect ratio based on screen size
        double aspectRatio;
        switch (screenType) {
          case ScreenType.mobile:
            aspectRatio = 1.5;
            break;
          case ScreenType.tablet:
            aspectRatio = 1.3;
            break;
          case ScreenType.desktop:
            aspectRatio = 1.2;
            break;
        }
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2),
          child: GridView.count(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                context,
                AppLocalizations.of(context).headingToCustomer, 
                headingToCustomer.toString(), 
                Icons.info_outline,
              ),
              _buildStatCard(
                context,
                AppLocalizations.of(context).awaitingAction, 
                awaitingAction.toString(), 
                Icons.info_outline, 
                valueColor: Colors.orange,
              ),
              _buildStatCard(
                context,
                AppLocalizations.of(context).successfulOrders, 
                successfulOrders.toString(), 
                Icons.info_outline, 
                showPercentage: true, 
                percentage: successRate,
              ),
              _buildStatCard(
                context,
                AppLocalizations.of(context).unsuccessfulOrders, 
                unsuccessfulOrders.toString(), 
                Icons.info_outline, 
                showPercentage: true, 
                percentage: unsuccessRate,
              ),
              _buildStatCard(
                context,
                AppLocalizations.of(context).headingToYou, 
                headingToYou.toString(), 
                Icons.info_outline,
              ),
              _buildStatCard(
                context,
                AppLocalizations.of(context).newOrders, 
                newOrders.toString(), 
                Icons.info_outline, 
                valueColor: Colors.black,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title, 
    String value, 
    IconData icon, 
    {bool showPercentage = false, 
    Color? valueColor, 
    double percentage = 0.0}
  ) {
    final screenType = ResponsiveUtils.getScreenType(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    // Responsive font sizes
    final titleFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      mobile: 12,
      tablet: 14,
      desktop: 16,
    );
    
    final valueFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      mobile: 18,
      tablet: 22,
      desktop: 26,
    );
    
    final percentageFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      mobile: 12,
      tablet: 14,
      desktop: 16,
    );
    
    // Responsive padding
    final cardPadding = screenType == ScreenType.mobile 
        ? EdgeInsets.all(spacing)
        : EdgeInsets.all(spacing + 4);
    
    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: titleFontSize,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing / 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: valueFontSize,
                    color: valueColor,
                  ),
                ),
              ),
              if (showPercentage) ...[
                SizedBox(width: spacing / 3),
                Text(
                  "${percentage.toStringAsFixed(0)}%",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: percentageFontSize,
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: EdgeInsets.all(spacing / 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 0.7, 
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}