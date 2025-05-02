import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tes1/features/common/widgets/app_text_field.dart';
import 'package:tes1/features/common/widgets/shimmer_loading.dart';
import 'package:tes1/core/widgets/toast_.dart' show ToastService, ToastType;
import 'package:tes1/features/business/home/screens/home_container.dart';
import '../providers/login_provider.dart';
import '../services/auth_service.dart';
import '../screens/signup_screen.dart';
import '../../business/dashboard/screens/dashboard_screen.dart';

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isPasswordVisible = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Email or Phone Number',
            hintText: 'johndoe@email.com or 1234567890',
            controller: emailController,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Email or phone number is required';
              
              // Check if input is a valid email (contains @)
              bool isEmail = val.contains('@');
              
              // Check if input is a valid phone number (only digits, minimum length of 10)
              bool isPhone = RegExp(r'^\d{10,}$').hasMatch(val);
              
              if (!isEmail && !isPhone) {
                return 'Enter a valid email or phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label:  'Password',
            hintText: '********',
            controller: passwordController,
            obscureText: !isPasswordVisible.value,
            suffixIcon: IconButton(
              icon: Icon(isPasswordVisible.value ? Icons.visibility : Icons.visibility_off),
              onPressed: () => isPasswordVisible.value = !isPasswordVisible.value,
            ),
            validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(''),
              Text(
              'Forgot Password?', 
              style: GoogleFonts.inter(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _handleLogin(context, ref, emailController.text, passwordController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFF89C29),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Consumer(
                builder: (_, ref, __) {
                  final isLoading = ref.watch(loginProvider);
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLoading
                        ? const ShimmerLoading(
                            baseColor: Colors.white70,
                            highlightColor: Colors.white,
                            child: SizedBox(
                              width: 80,
                              height: 20,
                              child: Center(
                                child: Text(
                                  'Logging in...',
                                  style: TextStyle(
                                    color: Colors.transparent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const Text('Login', 
                            key: ValueKey('login'), 
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Sign Up", 
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _handleLogin(BuildContext context, WidgetRef ref, String email, String password) async {
    // Set loading state
    ref.read(loginProvider.notifier).state = true;
    
    try {
      // Call login method from auth service
      final user = await ref.read(authServiceProvider).login(
        email: email,
        password: password,
      );
      
      if (!context.mounted) return;
      
      // Reset loading state
      ref.read(loginProvider.notifier).state = false;
      
      if (user != null) {
        // Refresh the user provider
        ref.refresh(currentUserProvider);
        
        // Check user role for navigation
        if (user.role == 'Business') {
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
          
          // For now, still navigate to HomeContainer
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeContainer()),
          );
        }
      } else {
        ToastService.show(
          context,
          'Login failed. Please check your credentials.',
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
