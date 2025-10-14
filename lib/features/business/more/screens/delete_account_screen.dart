import 'package:flutter/material.dart';
import 'delete_account_confirm_screen.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
      appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).deleteAccount,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 18, 
                tablet: 20, 
                desktop: 22,
              ),
            ),
          ),
      ),
      body: SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.isTablet(context) 
                    ? MediaQuery.of(context).size.width * 0.7
                    : double.infinity,
              ),
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
            
            // Warning icon
            Container(
              padding: ResponsiveUtils.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
              child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                size: ResponsiveUtils.getResponsiveIconSize(context) * 2.5,
              ),
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 2),
            
            // Warning title
            Text(
                AppLocalizations.of(context).deleteYourAccount,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context, 
                  mobile: 20, 
                  tablet: 24, 
                  desktop: 28,
                ),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
            
            // Warning message
            Text(
              AppLocalizations.of(context).deleteAccountWarning,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context, 
                  mobile: 14, 
                  tablet: 16, 
                  desktop: 18,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
            
            // Bullet points
            _buildBulletPoint(context, AppLocalizations.of(context).deletePersonalInfo),
            _buildBulletPoint(context, AppLocalizations.of(context).loseDataAccess),
            _buildBulletPoint(context, AppLocalizations.of(context).cancelSubscriptions),
            _buildBulletPoint(context, AppLocalizations.of(context).needNewAccount),
            
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 2),
            
            // Buttons
            ResponsiveUtils.isTablet(context) 
                ? Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context)),
                            side: const BorderSide(color: Color(0xfff29620)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).cancel, 
                            style: TextStyle(
                              color: const Color(0xfff29620),
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 
                                mobile: 14, 
                                tablet: 16, 
                                desktop: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DeleteAccountConfirmScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).continueAction,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 
                                mobile: 14, 
                                tablet: 16, 
                                desktop: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context)),
                      side: const BorderSide(color: Color(0xfff29620)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).cancel, 
                            style: TextStyle(
                              color: const Color(0xfff29620),
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 
                                mobile: 14, 
                                tablet: 16, 
                                desktop: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeleteAccountConfirmScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).continueAction,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 
                                mobile: 14, 
                                tablet: 16, 
                                desktop: 18,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context) * 0.8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ', 
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 14, 
                tablet: 16, 
                desktop: 18,
              ), 
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context, 
                  mobile: 14, 
                  tablet: 16, 
                  desktop: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 