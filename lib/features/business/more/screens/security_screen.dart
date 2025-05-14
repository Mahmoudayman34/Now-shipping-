import 'package:flutter/material.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password section
            _buildSectionTitle('Password'),
            const SizedBox(height: 8),
            
            ListTile(
              title: const Text('Change Password'),
              leading: const Icon(Icons.lock_outline, color: Color(0xfff29620)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            
            const Divider(),
            
            // Account security section
            _buildSectionTitle('Account Security'),
            const SizedBox(height: 8),
            
            _buildSecurityOption(
              context,
              title: 'Two-Factor Authentication',
              subtitle: 'Secure your account with 2FA',
              isEnabled: false,
              onToggle: (value) {
                // Implement 2FA toggle
                if (value) {
                  _showSetupTwoFactorDialog(context);
                }
              },
            ),
            
            const Divider(height: 1),
            
            _buildSecurityOption(
              context,
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or face recognition to log in',
              isEnabled: true,
              onToggle: (value) {
                // Implement biometric toggle
              },
            ),
            
            const Divider(height: 1),
            
            _buildSecurityOption(
              context,
              title: 'Remember Login',
              subtitle: 'Stay logged in for 30 days',
              isEnabled: true,
              onToggle: (value) {
                // Implement remember login toggle
              },
            ),
            
            // Privacy section
            _buildSectionTitle('Privacy'),
            const SizedBox(height: 8),
            
            ListTile(
              title: const Text('Privacy Settings'),
              leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xfff29620)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              onTap: () {
                // Navigate to privacy settings
              },
            ),
            
            const Divider(),
            
            ListTile(
              title: const Text('Delete Account'),
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              onTap: () {
                _showDeleteAccountDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
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
  
  Widget _buildSecurityOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isEnabled,
    required Function(bool) onToggle,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: isEnabled,
      onChanged: onToggle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    );
  }
  
  void _showSetupTwoFactorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Two-Factor Authentication'),
        content: const Text(
          'Two-factor authentication adds an extra layer of security to your account. We will guide you through the setup process.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to 2FA setup
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff29620),
            ),
            child: const Text('Setup Now'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmationDialog(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmationDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please enter your password to confirm account deletion:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Deletion'),
          ),
        ],
      ),
    );
  }
  
  void _deleteAccount(BuildContext context) {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Deleting account...'),
          ],
        ),
      ),
    );
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Account Deleted'),
          content: const Text(
            'Your account has been successfully deleted. You will be logged out now.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to login screen and clear navigation stack
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfff29620),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;
  
  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
  
  void changePassword() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      
      // Simulate API request
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create a new password that is at least 8 characters long and includes a combination of numbers, letters, and special characters.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              // Current password field
              TextFormField(
                controller: currentPasswordController,
                obscureText: !isCurrentPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isCurrentPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isCurrentPasswordVisible = !isCurrentPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // New password field
              TextFormField(
                controller: newPasswordController,
                obscureText: !isNewPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isNewPasswordVisible = !isNewPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Confirm password field
              TextFormField(
                controller: confirmPasswordController,
                obscureText: !isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isConfirmPasswordVisible = !isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfff29620),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Change Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 