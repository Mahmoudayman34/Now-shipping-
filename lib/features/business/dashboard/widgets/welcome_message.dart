import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';

class WelcomeMessage extends StatelessWidget {
  final String name;
  
  const WelcomeMessage({
    super.key,
    required this.name,
  });

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://nowshipping.co/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
        final spacing = ResponsiveUtils.getResponsiveSpacing(context) / 2;
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${AppLocalizations.of(context).hello}, ${name.split(' ')[0].toLowerCase()}! 👋',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 20,
                          tablet: 24,
                          desktop: 28,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Stack(
                  //   children: [
                  //     Container(
                  //       padding: const EdgeInsets.all(8),
                  //       decoration: BoxDecoration(
                  //         color: Colors.grey.withOpacity(0.1),
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //       child: Image.asset('assets/icons/notification.png', width: 24, height: 24,color: Colors.teal,),
                  //     ),
                  //     Positioned(
                  //       top: 0,
                  //       right: 0,
                  //       child: Container(
                  //         padding: const EdgeInsets.all(4),
                  //         decoration: const BoxDecoration(
                  //           color: Colors.red,
                  //           shape: BoxShape.circle,
                  //         ),
                  //         child: const Text(
                  //           '6',
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 10,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),

              SizedBox(height: spacing),

              Row(
                children: [
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context).moreFunctionalities,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: spacing / 2),
                  TextButton(
                    onPressed: _launchUrl,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context).visitDashboard,
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing / 4),
                        Icon(
                          Icons.open_in_new, 
                          color: Colors.teal, 
                          size: ResponsiveUtils.getResponsiveIconSize(context) * 0.6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}