import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:now_shipping/core/widgets/toast_.dart' show ToastService, ToastType;
import 'package:now_shipping/features/business/home/screens/home_container.dart';
import '../providers/login_provider.dart';
import '../services/auth_service.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../../../../core/layout/main_layout.dart'; // Add this import for the selectedTabIndexProvider

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isPasswordVisible = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final rememberMe = useState(false);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field with icon
          _buildTextField(
            controller: emailController,
            label: AppLocalizations.of(context).emailOrPhoneNumber,
            hintText: AppLocalizations.of(context).emailOrPhonePlaceholder,
            icon: Icons.email_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return AppLocalizations.of(context).emailOrPhoneRequired;
              
              // Check if input is a valid email (contains @)
              bool isEmail = val.contains('@');
              
              // Check if input is a valid phone number (only digits, minimum length of 10)
              bool isPhone = RegExp(r'^\d{10,}$').hasMatch(val);
              
              if (!isEmail && !isPhone) {
                return AppLocalizations.of(context).enterValidEmailOrPhone;
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Password field with icon
          _buildTextField(
            controller: passwordController,
            label: AppLocalizations.of(context).password,
            hintText: AppLocalizations.of(context).passwordPlaceholder,
            icon: Icons.lock_outline,
            obscureText: !isPasswordVisible.value,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: () => isPasswordVisible.value = !isPasswordVisible.value,
            ),
            validator: (val) => val == null || val.length < 6 ? AppLocalizations.of(context).minCharacters : null,
          ),
          
          const SizedBox(height: 16),
          
          // Remember me and Forgot password row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember me checkbox
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: rememberMe.value,
                      onChanged: (value) => rememberMe.value = value ?? false,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeColor: const Color(0xFF3266A2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).rememberMe,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              // Forgot password button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppLocalizations.of(context).forgotPassword,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF3266A2),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Login button with gradient
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _handleLogin(context, ref, emailController.text, passwordController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF89C29), Color(0xFFF7A540)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Consumer(
                    builder: (_, ref, __) {
                      final isLoading = ref.watch(loginProvider);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLoading) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            AppLocalizations.of(context).loginButton,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (!isLoading) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Sign up row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context).dontHaveAccount,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context).signUp, 
                  style: const TextStyle(
                    color: Color(0xFF3266A2),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Custom text field builder with icon
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            errorStyle: const TextStyle(fontSize: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }
  
  void _handleLogin(BuildContext context, WidgetRef ref, String email, String password) async {
    // Set loading state
    ref.read(loginProvider.notifier).state = true;
    
    try {
      // Call login method from auth service
      final user = await ref.read(authServiceProvider).login(
        email: email.replaceAll(' ', ''),
        password: password,
      );
      
      if (!context.mounted) return;
      
      // Reset loading state
      ref.read(loginProvider.notifier).state = false;
      
      if (user != null) {
        // Refresh the user provider
        ref.refresh(currentUserProvider);
        
        // Reset the selected tab index to 0 (Home)
        ref.read(selectedTabIndexProvider.notifier).state = 0;
        
        // Check user role for navigation
        if (user.role == 'Business') {   //Business
          // For Business role, navigate to HomeContainer
          // The _isProfileComplete variable will be used within the app
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeContainer()),
          );
        } else {
          // If no role specified or any other role, this is for delivery users
          // Navigate to delivery features (to be implemented later)
          ToastService.show(
            context,
            'Delivery features coming soon',
            type: ToastType.info,
          );
          
          
        }
      } else {
        ToastService.show(
          context,
            'Invalid email/phone number or password.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      
      // Reset loading state
      ref.read(loginProvider.notifier).state = false;
      
      ToastService.show(
        context,
        'Login error: $e',
        type: ToastType.error,
      );
    }
  }
}
