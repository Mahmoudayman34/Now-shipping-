import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_us_screen.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Function to launch URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).about,
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
          child: Column(
            children: [
              // App logo and version
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context) * 2.5),
                color: const Color(0xfff29620).withOpacity(0.05),
                child: Column(
                  children: [
                    Container(
                      width: ResponsiveUtils.getResponsiveImageSize(context) * 2.5,
                      height: ResponsiveUtils.getResponsiveImageSize(context) * 2.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: ResponsiveUtils.getResponsiveSpacing(context),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_shipping,
                          size: ResponsiveUtils.getResponsiveIconSize(context) * 1.25,
                          color: const Color(0xfff29620),
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                    Text(
                      'Now Shipping',
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
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 0.5),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context, 
                          mobile: 14, 
                          tablet: 16, 
                          desktop: 18,
                        ),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            
            // About app
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).aboutNowShipping,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context, 
                        mobile: 16, 
                        tablet: 18, 
                        desktop: 20,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xfff29620),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                  Text(
                    AppLocalizations.of(context).aboutDescription,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context, 
                        mobile: 14, 
                        tablet: 16, 
                        desktop: 18,
                      ),
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
                  
                  // Features
                  Text(
                    AppLocalizations.of(context).keyFeatures,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context, 
                        mobile: 16, 
                        tablet: 18, 
                        desktop: 20,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xfff29620),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                  _buildFeatureItem(context, AppLocalizations.of(context).easyOrderCreation),
                  _buildFeatureItem(context, AppLocalizations.of(context).realTimeTracking),
                  _buildFeatureItem(context, AppLocalizations.of(context).integratedPayments),
                  _buildFeatureItem(context, AppLocalizations.of(context).addressManagement),
                  _buildFeatureItem(context, AppLocalizations.of(context).analyticsReporting),
                  _buildFeatureItem(context, AppLocalizations.of(context).multiPlatformSupport),
                  
                  const SizedBox(height: 24),
                  
                  // Company info
                  Text(
                    AppLocalizations.of(context).companyInformation,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff29620),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCompanyInfo(context, AppLocalizations.of(context).founded, '2023'),
                  _buildCompanyInfo(context, AppLocalizations.of(context).headquarters, 'Cairo, Egypt'),
                  _buildCompanyInfo(context, AppLocalizations.of(context).website, 'www.nowshipping.com'),
                  _buildCompanyInfo(context, AppLocalizations.of(context).email, 'info@nowshipping.com'),
                  
                  const SizedBox(height: 24),
                  
                  // Legal info
                  Text(
                    AppLocalizations.of(context).legal,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff29620),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  InkWell(
                    onTap: () {
                      // Navigate to terms of service
                      _launchURL('https://nowshipping.co/terms-of-service');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.description_outlined, color: Color(0xfff29620)),
                          const SizedBox(width: 16),
                          Text(
                            AppLocalizations.of(context).termsOfService,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                  
                  InkWell(
                    onTap: () {
                      // Navigate to privacy policy
                      _launchURL('https://nowshipping.co/privacy-policy');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.privacy_tip_outlined, color: Color(0xfff29620)),
                          const SizedBox(width: 16),
                          Text(
                            AppLocalizations.of(context).privacyPolicy,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Contact button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to contact us
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactUsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfff29620),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(AppLocalizations.of(context).contactUs),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Copyright
                  Center(
                    child: Text(
                      AppLocalizations.of(context).allRightsReserved,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
  
  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context) * 0.8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: const Color(0xfff29620),
            size: ResponsiveUtils.getResponsiveIconSize(context),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context) * 0.8),
          Expanded(
            child: Text(
              feature,
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
  
  Widget _buildCompanyInfo(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context) * 0.8),
      child: Row(
        children: [
          SizedBox(
            width: ResponsiveUtils.getResponsiveSpacing(context) * 7.5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context, 
                  mobile: 14, 
                  tablet: 16, 
                  desktop: 18,
                ),
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context, 
                  mobile: 14, 
                  tablet: 16, 
                  desktop: 18,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  
  const LegalDocumentScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: June 15, 2023',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Sample legal text content
            Text(
              title == 'Terms of Service'
                  ? _getDummyTermsOfService()
                  : _getDummyPrivacyPolicy(),
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getDummyTermsOfService() {
    return '''
Welcome to Now Shipping. By using our services, you agree to these Terms of Service.

1. Acceptance of Terms

By accessing or using the Now Shipping platform, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our service.

2. Description of Service

Now Shipping provides a platform for businesses to manage their shipping operations, including order creation, tracking, and delivery management.

3. User Accounts

You must create an account to use our services. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.

4. User Conduct

You agree not to use the service for any illegal purposes or to conduct activities that violate the rights of others.

5. Fees and Payments

Fees for using our services are described on our pricing page. You agree to pay all applicable fees as they become due.

6. Termination

We reserve the right to terminate or suspend your account at any time for any reason without notice.

7. Changes to Terms

We may modify these terms at any time. Your continued use of the service after such modifications constitutes your acceptance of the modified terms.

8. Limitation of Liability

To the maximum extent permitted by law, Now Shipping shall not be liable for any indirect, incidental, special, consequential, or punitive damages.
''';
  }
  
  String _getDummyPrivacyPolicy() {
    return '''
This Privacy Policy describes how Now Shipping collects, uses, and discloses your information.

1. Information We Collect

We collect information you provide directly to us, such as your name, email address, phone number, and shipping information.

2. How We Use Your Information

We use the information we collect to provide, maintain, and improve our services, to communicate with you, and to comply with legal obligations.

3. Information Sharing

We do not sell your personal information. We may share your information with service providers who perform services on our behalf, or when required by law.

4. Security

We take reasonable measures to help protect your personal information from loss, theft, misuse, and unauthorized access.

5. Your Choices

You can access, update, or delete your account information at any time through your account settings.

6. Changes to this Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.

7. Contact Us

If you have any questions about this Privacy Policy, please contact us at privacy@nowshipping.com.
''';
  }
} 