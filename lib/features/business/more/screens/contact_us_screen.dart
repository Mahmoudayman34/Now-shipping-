import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/l10n/app_localizations.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  String _selectedIssueType = 'General Inquiry';
  bool _isSubmitting = false;
  
  final List<String> _issueTypes = [
    'General Inquiry',
    'Technical Support',
    'Billing Issue',
    'Shipping Problem',
    'Feature Request',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isSubmitting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your message has been sent. We\'ll get back to you soon.')),
        );
        
        // Clear the form
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        setState(() {
          _selectedIssueType = 'General Inquiry';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).contactUs,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact methods
            _buildContactCard(
              icon: Icons.location_on_outlined,
              title: AppLocalizations.of(context).ourOffice,
              details: [
                'New Cairo Business Park',
                '5th Settlement, Cairo, Egypt',
              ],
            ),
            
            _buildContactCard(
              icon: Icons.schedule_outlined,
              title: AppLocalizations.of(context).businessHours,
              details: [
                'Sunday - Thursday: 9:00 AM - 5:00 PM',
                'Friday - Saturday: Closed',
              ],
            ),
            
            _buildContactCard(
              icon: Icons.phone_outlined,
              title: AppLocalizations.of(context).phoneAndEmail,
              details: [
                '+20 123 456 7890',
                'support@nowshipping.com',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Contact form
            Text(
              AppLocalizations.of(context).sendUsMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xfff29620),
              ),
            ),
            const SizedBox(height: 16),
            
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).yourName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).yourEmail,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Issue type dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedIssueType,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).issueType,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: _issueTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedIssueType = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Message field
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).yourMessage,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      if (value.length < 10) {
                        return 'Message must be at least 10 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfff29620),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            )
                          : Text(AppLocalizations.of(context).sendMessage),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
  
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required List<String> details,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context)),
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: ResponsiveUtils.getResponsiveSpacing(context) * 0.5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context) * 0.6),
            decoration: BoxDecoration(
              color: const Color(0xfff29620).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xfff29620),
              size: ResponsiveUtils.getResponsiveIconSize(context),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 0.3),
                ...details.map((detail) => Padding(
                  padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context) * 0.3),
                  child: Text(
                    detail,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context, 
                        mobile: 12, 
                        tablet: 14, 
                        desktop: 16,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 