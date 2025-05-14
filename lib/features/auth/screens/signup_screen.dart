import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/core/utils/validators.dart';
import 'package:now_shipping/core/utils/responsive_utils.dart';
import 'package:now_shipping/core/widgets/toast_.dart' show ToastService, ToastType;
import 'package:now_shipping/features/auth/services/auth_service.dart';
import '../../common/widgets/app_text_field.dart';
import '../../common/widgets/shimmer_loading.dart';
import 'login_screen.dart';
import 'account_success_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // New controller for OTP verification
  final TextEditingController _otpController = TextEditingController();

  bool _wantsStorage = false;
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  // New state variables for phone verification
  final bool _isPhoneVerified = false;
  bool _showOtpField = false;
  bool _verifyingPhone = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ResponsiveUtils.wrapScreen(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/icons/icon_only.png',
                  height: 90,
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(height: 18),
              
              // Welcome text with animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Create Account",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: const Color(0xff3266a2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Fill in your details to get started",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
      
              // Form fields with staggered animation
              ...List.generate(4, (index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 600 + (index * 100)),
                  tween: Tween(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(30 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildFormField(index),
                  ),
                );
              }),
      
              const SizedBox(height: 8),
      
              // Checkboxes with improved styling
              Theme(
                data: theme.copyWith(
                  checkboxTheme: CheckboxThemeData(
                    
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "I want storage",
                        style: theme.textTheme.bodyMedium,
                      ),
                      value: _wantsStorage,
                      onChanged: (val) => setState(() => _wantsStorage = val ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFFF89C29),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "I agree to the terms and conditions",
                        style: theme.textTheme.bodyMedium,
                      ),
                      value: _agreeToTerms,
                      onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFFF89C29),
                    ),
                  ],
                ),
              ),
      
              const SizedBox(height: 32),
      
              // Submit button with elevation and gradient
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF89C29),
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                      ? const ShimmerLoading(
                          baseColor: Colors.white70,
                          highlightColor: Colors.white,
                          child: SizedBox(
                            width: 120,
                            height: 20,
                            child: Center(
                              child: Text(
                                "Creating Account...",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
      
              const SizedBox(height: 24),
      
              // Login text with better styling
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(int index) {
    switch (index) {
      case 0:
        return AppTextField(
          label: 'Full Name',
          controller: _nameController,
          hintText: 'Enter your full name',
          validator: Validators.name,
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phone Number'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Country code prefix
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: const Text(
                      '+2',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  // Phone number input
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !_isPhoneVerified,
                      decoration: const InputDecoration(
                        hintText: 'Enter your phone number',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  // Verify button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton(
                      onPressed: _isPhoneVerified ? null : _verifyPhone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPhoneVerified ? Colors.green : const Color(0xFFF89C29),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: _verifyingPhone 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_isPhoneVerified ? 'Verified' : 'Verify'),
                    ),
                  ),
                ],
              ),
            ),
            
            // OTP field that appears after clicking verify
            if (_showOtpField) ...[
              const SizedBox(height: 16),
              const Text('Enter 6-digit OTP sent to your phone'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          hintText: '6-digit code',
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (value) {
                          if (_showOtpField && (value == null || value.length < 6)) {
                            return 'Please enter the complete 6-digit OTP';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      case 2:
        return AppTextField(
          label: 'Email',
          controller: _emailController,
          hintText: 'Enter your email address',
          validator: Validators.email,
        );
      case 3:
        return AppTextField(
          label: 'Password',
          controller: _passwordController,
          hintText: 'Create a password',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: Validators.password,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ToastService.show(
          context,
          "Please agree to terms and conditions",
          type: ToastType.error,
        );
        return;
      }

      if (!_isPhoneVerified && _otpController.text.isEmpty) {
        ToastService.show(
          context,
          "Please verify your phone number",
          type: ToastType.error,
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Call the signup API
      final authService = ref.read(authServiceProvider);
      authService.signup(
        email: _emailController.text.trim(),
        fullName: _nameController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        storageCheck: _wantsStorage,
        termsCheck: _agreeToTerms,
        otp: _otpController.text.trim(),
      ).then((response) {
        setState(() {
          _isLoading = false;
        });
        
        // Check the response status and show appropriate message
        if (response['status'] == 'success') {
          // Show success message
          ToastService.show(
            context,
            response['message'] ?? 'Account created successfully!',
            type: ToastType.success,
          );
          
          // Navigate to login screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else {
          // Show error message
          ToastService.show(
            context,
            response['message'] ?? 'Failed to create account',
            type: ToastType.error,
          );
        }
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ToastService.show(
          context,
          "Error: ${error.toString()}",
          type: ToastType.error,
        );
      });
      
      FocusScope.of(context).unfocus();
    }
  }

  void _verifyPhone() {
    // Validate phone number first
    if (_phoneController.text.isEmpty) {
      ToastService.show(
        context,
        "Please enter a phone number",
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _verifyingPhone = true;
    });

    // Call the API to send OTP
    final authService = ref.read(authServiceProvider);
    authService.sendOtp(_phoneController.text).then((message) {
      setState(() {
        _verifyingPhone = false;
        _showOtpField = true;
      });
      
      if (message != null) {
        // Show success message from API
        ToastService.show(
          context,
          "OTP sent successfully",
          type: ToastType.success,
        );
      } else {
        // Show error message if API call failed
        ToastService.show(
          context,
          "Failed to send OTP. Please try again.",
          type: ToastType.error,
        );
        setState(() {
          _showOtpField = false;
        });
      }
    }).catchError((error) {
      setState(() {
        _verifyingPhone = false;
      });
      
      // Show error message
      ToastService.show(
        context,
        "Error: ${error.toString()}",
        type: ToastType.error,
      );
    });
  }
}