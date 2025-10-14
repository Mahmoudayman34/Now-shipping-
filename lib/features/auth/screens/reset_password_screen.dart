import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui';
import '../../../core/l10n/app_localizations.dart';
import 'package:now_shipping/core/widgets/toast_.dart' show ToastService, ToastType;
import '../providers/forgot_password_provider.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends HookConsumerWidget {
  final String token;
  
  const ResetPasswordScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final isPasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isPasswordReset = useState(false);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Shipping-themed background
            ...buildShippingBackgroundElements(),
            
            // Main content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      
                      // Back button
                      Align(
                        alignment: Directionality.of(context) == TextDirection.rtl 
                          ? Alignment.centerRight 
                          : Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF3266A2),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Logo with shadow
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icons/icon_only.png',
                          height: 80,
                          alignment: Alignment.center,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Title with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            const Color(0xff3266a2),
                            const Color(0xff3266a2).withBlue(180),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          isPasswordReset.value 
                            ? AppLocalizations.of(context).passwordResetSuccessfully
                            : AppLocalizations.of(context).resetPassword,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        isPasswordReset.value 
                          ? AppLocalizations.of(context).passwordResetSuccessDescription
                          : AppLocalizations.of(context).resetPasswordDescription,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Form container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: isPasswordReset.value 
                          ? _buildPasswordResetSuccessContent(context)
                          : _buildResetPasswordForm(context, ref, newPasswordController, confirmPasswordController, formKey, isPasswordVisible, isConfirmPasswordVisible, isPasswordReset),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetPasswordForm(
    BuildContext context, 
    WidgetRef ref, 
    TextEditingController newPasswordController,
    TextEditingController confirmPasswordController,
    GlobalKey<FormState> formKey,
    ValueNotifier<bool> isPasswordVisible,
    ValueNotifier<bool> isConfirmPasswordVisible,
    ValueNotifier<bool> isPasswordReset,
  ) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New password field
          _buildTextField(
            controller: newPasswordController,
            label: AppLocalizations.of(context).newPassword,
            hintText: AppLocalizations.of(context).newPasswordPlaceholder,
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
            validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
          ),
          
          const SizedBox(height: 20),
          
          // Confirm password field
          _buildTextField(
            controller: confirmPasswordController,
            label: AppLocalizations.of(context).confirmNewPassword,
            hintText: AppLocalizations.of(context).confirmNewPasswordPlaceholder,
            icon: Icons.lock_outline,
            obscureText: !isConfirmPasswordVisible.value,
            suffixIcon: IconButton(
              icon: Icon(
                isConfirmPasswordVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: () => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value,
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please confirm your password';
              if (val != newPasswordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          
          const SizedBox(height: 32),
          
          // Reset password button with gradient
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _handleResetPassword(context, ref, newPasswordController.text, isPasswordReset);
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
                      final isLoading = ref.watch(forgotPasswordProvider);
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
                            AppLocalizations.of(context).resetPassword,
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
        ],
      ),
    );
  }

  Widget _buildPasswordResetSuccessContent(BuildContext context) {
    return Column(
      children: [
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 40,
            color: Colors.green,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          AppLocalizations.of(context).passwordResetSuccessfully,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3266A2),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          AppLocalizations.of(context).passwordResetSuccessDescription,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Go to login button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
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
                child: Text(
                  AppLocalizations.of(context).goToLogin,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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

  void _handleResetPassword(
    BuildContext context, 
    WidgetRef ref, 
    String newPassword,
    ValueNotifier<bool> isPasswordReset,
  ) async {
    // Set loading state
    ref.read(forgotPasswordProvider.notifier).state = true;
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (!context.mounted) return;
    
    // Reset loading state
    ref.read(forgotPasswordProvider.notifier).state = false;
    
    // Mock successful password reset
    isPasswordReset.value = true;
    
    ToastService.show(
      context,
      AppLocalizations.of(context).passwordResetSuccessfullyToast,
      type: ToastType.success,
    );
  }

  List<Widget> buildShippingBackgroundElements() {
    // Use your app's color scheme - blue and orange
    const Color blueColor = Color(0xFF3266A2);
    const Color orangeColor = Color(0xFFF89C29);
    
    return [
      // Background color
      Positioned.fill(
        child: Container(
          color: Colors.white,
        ),
      ),
      
      // Top gradient
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: 200,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                blueColor.withOpacity(0.05),
                Colors.white.withOpacity(0),
              ],
            ),
          ),
        ),
      ),
      
      // Simple decorative elements
      Positioned(
        top: 30,
        right: 20,
        child: const Opacity(
          opacity: 0.07,
          child: Icon(
            Icons.local_shipping_outlined,
            size: 60,
            color: blueColor,
          ),
        ),
      ),
      
      Positioned(
        top: 120,
        left: 20,
        child: const Opacity(
          opacity: 0.07,
          child: Icon(
            Icons.inventory_2_outlined,
            size: 50,
            color: orangeColor,
          ),
        ),
      ),
      
      // Bottom gradient
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        height: 200,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                orangeColor.withOpacity(0.05),
                Colors.white.withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}
