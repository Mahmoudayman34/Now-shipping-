import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';

class CashSummary extends StatelessWidget {
  final double expectedCash;
  final double collectedCash;
  final double collectionRate;
  
  const CashSummary({
    super.key,
    required this.expectedCash,
    required this.collectedCash,
    this.collectionRate = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
        final spacing = ResponsiveUtils.getResponsiveSpacing(context);
        final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2),
          child: Container(
            padding: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Column(
              children: [
                _buildCashItem(
                  context, 
                  AppLocalizations.of(context).expectedCash, 
                  "${expectedCash.toStringAsFixed(1)} ${AppLocalizations.of(context).egp}",
                ),
                _buildCashItem(
                  context, 
                  AppLocalizations.of(context).collectedCash, 
                  "${collectedCash.toStringAsFixed(1)} ${AppLocalizations.of(context).egp}", 
                  valueColor: Colors.green, 
                  showPercentage: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCashItem(BuildContext context, String label, String value, {Color? valueColor, bool showPercentage = false}) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context) / 4;
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context) / 2;
    
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  color: valueColor,
                ),
              ),
              if (showPercentage) ...[
                SizedBox(width: spacing * 2),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing * 1.5, 
                    vertical: spacing / 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Text(
                    "${collectionRate.toStringAsFixed(0)} %",
                    style: TextStyle(
                      color: valueColor ?? Colors.grey,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 10,
                        tablet: 12,
                        desktop: 14,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}