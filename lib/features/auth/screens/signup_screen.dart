import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/core/utils/validators.dart';
import 'package:tes1/core/utils/responsive_utils.dart';
import 'package:tes1/core/widgets/toast_.dart' show ToastService, ToastType;
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

  bool _wantsStorage = false;
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
        return AppTextField(
          label: 'Phone Number',
          controller: _phoneController,
          hintText: 'Enter your phone number',
          validator: Validators.phone,
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

      setState(() {
        _isLoading = true;
      });

      // Simulate API call to create account
      Future.delayed(const Duration(seconds: 2), () {
        // Here you would actually create the user account
        
        setState(() {
          _isLoading = false;
        });

        // Navigate to success screen instead of showing a snackbar
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AccountSuccessScreen(),
          ),
        );
      });
      
      FocusScope.of(context).unfocus();
    }
  }
}