import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:tes1/core/widgets/toast_.dart' show ToastService, ToastType;
import 'package:tes1/features/business/dashboard/providers/profile_form_provider.dart';
import '../../../auth/services/auth_service.dart';
import 'profile_completion_form.dart';

class DashboardEmailVerification extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final GlobalKey<FormState>? formKey;
  final Function(Function)? onRegisterSave;
  
  const DashboardEmailVerification({
    super.key, 
    required this.onComplete,
    this.formKey,
    this.onRegisterSave,
  });

  @override
  ConsumerState<DashboardEmailVerification> createState() => _DashboardEmailVerificationState();
}

class _DashboardEmailVerificationState extends ConsumerState<DashboardEmailVerification> {
  bool _isResending = false;
  Timer? _resendTimer;
  int _remainingSeconds = 60;
  bool _isVerified = false;
  String? _email;
  
  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadSavedData();
    _startResendTimer();
    
    // Register save callback
    if (widget.onRegisterSave != null) {
      widget.onRegisterSave!(_saveFormData);
    }
  }
  
  Future<void> _loadSavedData() async {
    final data = ref.read(profileFormDataProvider);
    if (data.containsKey('emailVerified')) {
      setState(() {
        _isVerified = data['emailVerified'] as bool;
      });
    }
  }
  
  Future<void> _loadUserEmail() async {
    final user = await ref.read(authServiceProvider).getCurrentUser();
    if (mounted) {
      setState(() {
        _email = user?.email;
      });
    }
  }
  
  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
  
  void _startResendTimer() {
    _remainingSeconds = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  void _resendVerificationEmail() {
    if (_remainingSeconds > 0) return;
    
    setState(() {
      _isResending = true;
    });
    
    // Simulate API call to resend verification email
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        
        ToastService.show(
          context,
          'Verification email sent to ${_email ?? "your email address"}',
          type: ToastType.success,
        );
        
        _startResendTimer();
      }
    });
  }

  // Method to save current form data
  void _saveFormData() {
    // Save current state to the provider
    final currentData = ref.read(profileFormDataProvider);
    ref.read(profileFormDataProvider.notifier).state = {
      ...currentData,
      'emailVerified': _isVerified,
    };
    debugPrint('Email verification step data saved: $_isVerified');
  }

  void _verifyEmail() {
    setState(() {
      _isVerified = true;
    });
    
    // Simulate verification success
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Save verification status in the form data
        _saveFormData();
        
        // Move to next step using the callback
        widget.onComplete();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isVerified) ...[
               //Animation
            SizedBox(
              height: 200,
              child: Lottie.asset(
                'assets/animations/email_verfication.json',
                animate: _isVerified,

                
              ),
             ),
            ],
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              _isVerified 
                  ? "Email Verified!" 
                  : "Verify Your Email",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _isVerified ? Colors.green : theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              _isVerified
                  ? "Your email has been successfully verified."
                  : "We've sent a verification link to ${_email ?? "your email address"}. Please check your inbox and click the link to verify your email address.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Verification buttons
            if (!_isVerified) ...[
              // I've verified my email button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "I've verified my email",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Resend email button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _remainingSeconds > 0 || _isResending
                      ? null
                      : _resendVerificationEmail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isResending
                      ? const CircularProgressIndicator()
                      : Text(
                          _remainingSeconds > 0
                              ? "Resend email (${_remainingSeconds}s)"
                              : "Resend verification email",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _remainingSeconds > 0
                                ? theme.disabledColor
                                : theme.colorScheme.primary,
                          ),
                        ),
                ),
              ),
            ] else ...[
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}