import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_us_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App logo and version
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              color: const Color(0xfff29620).withOpacity(0.05),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_shipping,
                        size: 50,
                        color: Color(0xfff29620),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Now Shipping',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // About app
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Now Shipping',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff29620),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Now Shipping is a modern shipping management platform designed for businesses of all sizes. Our platform helps you manage your shipping operations efficiently, from creating orders to tracking deliveries.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Features
                  const Text(
                    'Key Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff29620),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem('Easy order creation and management'),
                  _buildFeatureItem('Real-time shipment tracking'),
                  _buildFeatureItem('Integrated payment solutions'),
                  _buildFeatureItem('Customer address management'),
                  _buildFeatureItem('Analytics and reporting'),
                  _buildFeatureItem('Multi-platform support'),
                  
                  const SizedBox(height: 24),
                  
                  // Company info
                  const Text(
                    'Company Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff29620),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCompanyInfo('Founded', '2023'),
                  _buildCompanyInfo('Headquarters', 'Cairo, Egypt'),
                  _buildCompanyInfo('Website', 'www.nowshipping.com'),
                  _buildCompanyInfo('Email', 'info@nowshipping.com'),
                  
                  const SizedBox(height: 24),
                  
                  // Legal info
                  const Text(
                    'Legal',
                    style: TextStyle(
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
                          const Text(
                            'Terms of Service',
                            style: TextStyle(fontSize: 16),
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
                          const Text(
                            'Privacy Policy',
                            style: TextStyle(fontSize: 16),
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
                      child: const Text('Contact Us'),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Copyright
                  Center(
                    child: Text(
                      '© ${DateTime.now().year} Now Shipping. All rights reserved.',
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
    );
  }
  
  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xfff29620),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompanyInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
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