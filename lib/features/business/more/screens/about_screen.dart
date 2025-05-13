import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'contact_us_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LegalDocumentScreen(
                            title: 'Terms of Service',
                          ),
                        ),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WebViewLegalScreen(
                            title: 'Privacy Policy',
                            url: 'https://nowshipping.co/privacy-policy',
                          ),
                        ),
                      );
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

class WebViewLegalScreen extends StatefulWidget {
  final String title;
  final String url;
  
  const WebViewLegalScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<WebViewLegalScreen> createState() => _WebViewLegalScreenState();
}

class _WebViewLegalScreenState extends State<WebViewLegalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const SafeArea(
        child: PrivacyPolicyContent(),
      ),
    );
  }
}

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last updated: May 09, 2025',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          const Text(
            'PRIVACY POLICY',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Now Shipping',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          
          const Text(
            'This Privacy Notice for Now Shipping ("we," "us," or "our"), describes how and why we might access, collect, store, use, and/or share ("process") your personal information when you use our services ("Services"), including when you:',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 16),
          
          _buildBulletPoint('Visit our website at https://nowshipping.co'),
          _buildBulletPoint('Download and use our mobile application (Now Shipping)'),
          _buildBulletPoint('Engage with us in other related ways, including sales, marketing, or events'),
          
          const SizedBox(height: 16),
          
          const Text(
            'Questions or concerns? Reading this Privacy Notice will help you understand your privacy rights and choices. If you do not agree with our policies and practices, please do not use our Services. If you still have any questions or concerns, please contact us at info@nowshipping.co.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('SUMMARY OF KEY POINTS'),
          
          const Text(
            'This summary provides key points from our Privacy Notice, but you can find out more details about any of these topics by clicking the link following each key point or by using our table of contents below to find the section you are looking for.',
            style: TextStyle(fontSize: 16, height: 1.5, fontStyle: FontStyle.italic),
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('What personal information do we process?'),
          
          const Text(
            'When you visit, use, or navigate our Services, we may process personal information depending on how you interact with us and the Services, the choices you make, and the products and features you use. This includes:',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          
          const SizedBox(height: 8),
          _buildDetailBullet('Full name and contact details (email address, phone number)'),
          _buildDetailBullet('Delivery addresses and shipping preferences'),
          _buildDetailBullet('Payment information and transaction history'),
          _buildDetailBullet('Login credentials and account settings'),
          _buildDetailBullet('Device information and usage data when using our app'),
          
          const SizedBox(height: 16),
          _buildSectionTitle('How do we process your information?'),
          
          const Text(
            'We process your information to provide, improve, and administer our Services, communicate with you, for security and fraud prevention, and to comply with legal obligations. We may also process your information for other purposes with your explicit consent. Specifically, we process your information to:',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          
          const SizedBox(height: 8),
          _buildDetailBullet('Create and maintain your account with us'),
          _buildDetailBullet('Deliver products and services you request, including tracking shipments'),
          _buildDetailBullet('Send you transaction confirmations, updates, and service notifications'),
          _buildDetailBullet('Improve our Services and develop new features based on usage patterns'),
          _buildDetailBullet('Ensure the security of your account and our platform'),
          
          const SizedBox(height: 16),
          _buildSectionTitle('With whom do we share your information?'),
          
          const Text(
            'We only share your personal information with service providers under contract who help with our business operations (such as delivery partners and payment processors). We do not sell your personal information to third parties. We may share information in these situations:',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          
          const SizedBox(height: 8),
          _buildDetailBullet('With delivery partners to complete your shipping requests'),
          _buildDetailBullet('With payment processors to complete transactions'),
          _buildDetailBullet('When required by law or to protect our legal rights'),
          _buildDetailBullet('In the event of a business transfer, merger, or acquisition'),
          
          const SizedBox(height: 16),
          _buildSectionTitle('How do we keep your information safe?'),
          
          const Text(
            'We implement appropriate technical and organizational security measures designed to protect the security of any personal information we process. However, despite our safeguards, no electronic transmission or storage system is 100% secure, so we cannot guarantee absolute security of your data.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('What are your privacy rights?'),
          
          const Text(
            'Depending on your location, you may have the right to:',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          
          const SizedBox(height: 8),
          _buildDetailBullet('Access and receive a copy of your personal data'),
          _buildDetailBullet('Request correction of incomplete or inaccurate information'),
          _buildDetailBullet('Request deletion of your personal information'),
          _buildDetailBullet('Withdraw your consent for processing of your data'),
          _buildDetailBullet('Lodge a complaint with your local data protection authority'),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Updates to this Policy'),
          
          const Text(
            'We may update this Privacy Policy from time to time to reflect changes to our practices or for other operational, legal, or regulatory reasons. The updated version will be indicated by an updated "Last Updated" date at the top of this Privacy Policy.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          
          const SizedBox(height: 24),
          
          _buildContactInfo(),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          Center(
            child: Text(
              '© ${DateTime.now().year} Now Shipping. All rights reserved.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, height: 1.5)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[700])),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xfff29620),
        ),
      ),
    );
  }
  
  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xfff29620).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xfff29620),
            ),
          ),
          const SizedBox(height: 12),
          _buildContactRow(Icons.email, 'info@nowshipping.co'),
          _buildContactRow(Icons.phone, '+20 123 456 7890'),
          _buildContactRow(Icons.location_on, 'Abdeen, Cairo Governorate, Egypt'),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.language, size: 20, color: Color(0xfff29620)),
              SizedBox(width: 8),
              Text(
                'Full Privacy Policy:',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              'https://nowshipping.co/privacy-policy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[700],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xfff29620)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
} 