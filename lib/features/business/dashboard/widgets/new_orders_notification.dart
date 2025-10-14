import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';

class NewOrdersNotification extends StatelessWidget {
  final int newOrdersCount;
  
  const NewOrdersNotification({
    super.key,
    required this.newOrdersCount,
  });

  void _showPreparationSteps(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Pull indicator
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            // Header with gradient
            Container(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal.shade400, Colors.teal.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).preparingYourOrders,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1D1B20),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context).followProfessionalSteps,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(height: 1, thickness: 1, color: Colors.grey[100]),
            
            // Steps list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  _buildProfessionalStep(
                    context: context,
                    step: 1,
                    title: AppLocalizations.of(context).verifyOrderInformation,
                    description: AppLocalizations.of(context).doubleCheckCustomerDetails,
                    icon: Icons.fact_check_outlined,
                    iconBackgroundColor: const Color(0xFF1ABC9C),
                  ),
                  
                  _buildProfessionalStep(
                    context: context,
                    step: 2,
                    title: AppLocalizations.of(context).selectProperPackaging,
                    description: AppLocalizations.of(context).chooseAppropriatePackaging,
                    icon: Icons.inventory_2_outlined,
                    iconBackgroundColor: const Color(0xFF3498DB),
                  ),
                  
                  _buildProfessionalStep(
                    context: context,
                    step: 3,
                    title: AppLocalizations.of(context).securePackageContents,
                    description: AppLocalizations.of(context).useProperCushioning,
                    icon: Icons.security_outlined,
                    iconBackgroundColor: const Color(0xFF9B59B6),
                  ),
                  
                  _buildProfessionalStep(
                    context: context,
                    step: 4,
                    title: AppLocalizations.of(context).applyShippingLabel,
                    description: AppLocalizations.of(context).printAndAffixLabels,
                    icon: Icons.print_outlined,
                    iconBackgroundColor: const Color(0xFFE74C3C),
                  ),
                  
                  _buildProfessionalStep(
                    context: context,
                    step: 5,
                    title: AppLocalizations.of(context).schedulePickup,
                    description: AppLocalizations.of(context).arrangeForPickup,
                    icon: Icons.schedule_outlined,
                    iconBackgroundColor: const Color(0xFFF39C12),
                    isLast: true,
                  ),
                ],
              ),
            ),
            
            // Bottom section with button
            Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A2B9),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  AppLocalizations.of(context).readyToPrepare,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalStep({
    required BuildContext context,
    required int step,
    required String title,
    required String description,
    required IconData icon,
    required Color iconBackgroundColor,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number with connected line
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF26A2B9), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    step.toString(),
                    style: const TextStyle(
                      color: Color(0xFF26A2B9),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF26A2B9),
                        const Color(0xFF26A2B9).withOpacity(0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Content container
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconBackgroundColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: iconBackgroundColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff1D1B20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
        final spacing = ResponsiveUtils.getResponsiveSpacing(context);
        final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
        final iconSize = ResponsiveUtils.getResponsiveIconSize(context);
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2),
          child: Container(
            padding: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/pickup.png', 
                      width: iconSize + 6, 
                      height: iconSize + 6, 
                      color: Colors.teal,
                    ),
                    SizedBox(width: spacing / 2),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ), 
                            color: const Color(0xff1D1B20),
                          ), 
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context).youHaveCreatedOrders.replaceAll('{count}', '$newOrdersCount'),
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showPreparationSteps(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.teal),
                      padding: EdgeInsets.all(spacing / 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).prepareOrders, 
                      style: TextStyle(
                        color: Colors.teal,
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
          ),
        );
      },
    );
  }
}