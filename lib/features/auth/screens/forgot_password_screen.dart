import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui';
import '../../../core/l10n/app_localizations.dart';
import 'package:now_shipping/core/widgets/toast_.dart' show ToastService, ToastType;
import '../providers/forgot_password_provider.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final otpController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final currentStep = useState(0); // 0: email, 1: OTP, 2: success
    final userEmail = useState('');
    final resetToken = useState('');

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
                          AppLocalizations.of(context).forgotPassword,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        _getDescriptionText(context, currentStep.value),
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
                        child: _buildStepContent(context, ref, currentStep.value, emailController, otpController, formKey, userEmail, resetToken, currentStep),
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

  String _getDescriptionText(BuildContext context, int step) {
    switch (step) {
      case 0:
        return AppLocalizations.of(context).forgotPasswordDescription;
      case 1:
        return AppLocalizations.of(context).otpSentToEmail;
      case 2:
        return AppLocalizations.of(context).otpVerifiedDescription;
      default:
        return AppLocalizations.of(context).forgotPasswordDescription;
    }
  }

  Widget _buildStepContent(
    BuildContext context, 
    WidgetRef ref, 
    int step,
    TextEditingController emailController,
    TextEditingController otpController,
    GlobalKey<FormState> formKey,
    ValueNotifier<String> userEmail,
    ValueNotifier<String> resetToken,
    ValueNotifier<int> currentStep,
  ) {
    switch (step) {
      case 0:
        return _buildForgotPasswordForm(context, ref, emailController, formKey, userEmail, currentStep);
      case 1:
        return _buildOtpVerificationForm(context, ref, otpController, formKey, userEmail, resetToken, currentStep);
      case 2:
        return _buildOtpVerifiedContent(context, ref, resetToken);
      default:
        return _buildForgotPasswordForm(context, ref, emailController, formKey, userEmail, currentStep);
    }
  }

  Widget _buildForgotPasswordForm(
    BuildContext context, 
    WidgetRef ref, 
    TextEditingController emailController, 
    GlobalKey<FormState> formKey,
    ValueNotifier<String> userEmail,
    ValueNotifier<int> currentStep,
  ) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field with icon
          _buildTextField(
            controller: emailController,
            label: AppLocalizations.of(context).emailAddress,
            hintText: AppLocalizations.of(context).enterEmailAddress,
            icon: Icons.email_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Email is required';
              
              // Check if input is a valid email
              bool isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val);
              
              if (!isEmail) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 32),
          
          // Send reset link button with gradient
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _handleForgotPassword(context, ref, emailController.text, userEmail, currentStep);
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
                            AppLocalizations.of(context).sendResetLink,
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
          
          const SizedBox(height: 24),
          
          // Back to login
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context).backToLogin,
                style: GoogleFonts.inter(
                  color: const Color(0xFF3266A2),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerificationForm(
    BuildContext context, 
    WidgetRef ref, 
    TextEditingController otpController,
    GlobalKey<FormState> formKey,
    ValueNotifier<String> userEmail,
    ValueNotifier<String> resetToken,
    ValueNotifier<int> currentStep,
  ) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OTP field with icon
          _buildTextField(
            controller: otpController,
            label: AppLocalizations.of(context).otpCode,
            hintText: AppLocalizations.of(context).otpCodePlaceholder,
            icon: Icons.security_outlined,
            validator: (val) {
              if (val == null || val.isEmpty) return 'OTP code is required';
              if (val.length != 6) return 'OTP code must be 6 digits';
              return null;
            },
          ),
          
          const SizedBox(height: 32),
          
          // Verify OTP button with gradient
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _handleVerifyOtp(context, ref, userEmail.value, otpController.text, resetToken, currentStep);
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
                            AppLocalizations.of(context).verifyOtp,
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
          
          const SizedBox(height: 24),
          
          // Resend OTP
          Center(
            child: TextButton(
              onPressed: () {
                _handleResendOtp(context, ref, userEmail.value);
              },
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppLocalizations.of(context).resendOtp,
                style: GoogleFonts.inter(
                  color: const Color(0xFF3266A2),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Back to login
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context).backToLogin,
                style: GoogleFonts.inter(
                  color: const Color(0xFF3266A2),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerifiedContent(BuildContext context, WidgetRef ref, ValueNotifier<String> resetToken) {
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
          AppLocalizations.of(context).otpVerified,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3266A2),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          AppLocalizations.of(context).otpVerifiedDescription,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Continue to reset password button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ResetPasswordScreen(token: resetToken.value),
                ),
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
                  AppLocalizations.of(context).continueToResetPassword,
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
        
        const SizedBox(height: 16),
        
        // Back to login
        Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context).backToLogin,
              style: GoogleFonts.inter(
                color: const Color(0xFF3266A2),
                fontWeight: FontWeight.w600,
                fontSize: 14,
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

  void _handleForgotPassword(
    BuildContext context, 
    WidgetRef ref, 
    String email, 
    ValueNotifier<String> userEmail,
    ValueNotifier<int> currentStep,
  ) async {
    // Set loading state
    ref.read(forgotPasswordProvider.notifier).state = true;
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (!context.mounted) return;
    
    // Reset loading state
    ref.read(forgotPasswordProvider.notifier).state = false;
    
    // Mock successful response
    userEmail.value = email;
    currentStep.value = 1; // Move to OTP step
    
    ToastService.show(
      context,
      AppLocalizations.of(context).otpSentSuccessfully,
      type: ToastType.success,
    );
  }

  void _handleVerifyOtp(
    BuildContext context, 
    WidgetRef ref, 
    String email,
    String otp,
    ValueNotifier<String> resetToken,
    ValueNotifier<int> currentStep,
  ) async {
    // Set loading state
    ref.read(forgotPasswordProvider.notifier).state = true;
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (!context.mounted) return;
    
    // Reset loading state
    ref.read(forgotPasswordProvider.notifier).state = false;
    
    // Mock OTP verification (accept any 6-digit code)
    if (otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp)) {
      // Store mock reset token and move to success step
      resetToken.value = 'mock_reset_token_${DateTime.now().millisecondsSinceEpoch}';
      currentStep.value = 2; // Move to success step
      
      ToastService.show(
        context,
        AppLocalizations.of(context).otpVerifiedSuccessfully,
        type: ToastType.success,
      );
    } else {
      ToastService.show(
        context,
        AppLocalizations.of(context).invalidOtpCode,
        type: ToastType.error,
      );
    }
  }

  void _handleResendOtp(
    BuildContext context, 
    WidgetRef ref, 
    String email,
  ) async {
    // Set loading state
    ref.read(forgotPasswordProvider.notifier).state = true;
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (!context.mounted) return;
    
    // Reset loading state
    ref.read(forgotPasswordProvider.notifier).state = false;
    
    // Mock successful resend
    ToastService.show(
      context,
      AppLocalizations.of(context).otpResentSuccessfully,
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
