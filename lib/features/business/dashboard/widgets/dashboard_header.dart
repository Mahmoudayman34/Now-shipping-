import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  
  const DashboardHeader({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
        final topPadding = ResponsiveUtils.getResponsiveFontSize(
          context,
          mobile: 20,
          tablet: 24,
          desktop: 28,
        );
        final iconSize = ResponsiveUtils.getResponsiveImageSize(context);
        final logoSize = ResponsiveUtils.getResponsiveFontSize(
          context,
          mobile: 70,
          tablet: 80,
          desktop: 90,
        );
        final spacing = ResponsiveUtils.getResponsiveSpacing(context) / 2;
        
        return Padding(
          padding: EdgeInsets.only(
            top: topPadding,
            left: padding.horizontal / 2,
            right: padding.horizontal / 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: iconSize,
                    width: iconSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(
                        Radius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/icon_only.png',
                        width: iconSize + 10,
                        height: iconSize + 10,
                        color: const Color(0xfff29620),
                      ),
                    ),
                  ),
                  SizedBox(width: spacing),
                  Image.asset(
                    'assets/images/word_only.png',
                    width: logoSize,
                    height: logoSize,
                  ),
                  SizedBox(width: spacing / 2),
                ],
              ),
              // Row(
              //   children: [
              //     Container(
              //       padding: const EdgeInsets.all(4),
              //       decoration: BoxDecoration(
              //         color: Colors.red.withOpacity(0.1),
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //       child: Image.asset('assets/icons/receipt.png', width: 16, height: 16),
              //     ),
              //     const SizedBox(width: 12),
              //     Container(
              //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              //       decoration: BoxDecoration(
              //         color: Colors.grey.shade500.withOpacity(0.1),
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //       child: Row(

              //         children: [
              //           Image.asset('assets/icons/support.png', width: 24, height: 24,
              //             color: Colors.teal),
              //           const SizedBox(width: 4),
              //           const Text('Support', style: TextStyle(color: Colors.teal)),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        );
      },
    );
  }
}