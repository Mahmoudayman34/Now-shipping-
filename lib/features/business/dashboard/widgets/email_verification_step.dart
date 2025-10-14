import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:now_shipping/core/widgets/toast_.dart' show ToastService, ToastType;
import 'package:now_shipping/features/business/dashboard/providers/profile_form_provider.dart';
import 'package:now_shipping/features/business/dashboard/providers/dashboard_provider.dart';
import '../../../auth/services/auth_service.dart';

class DashboardEmailVerification extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final GlobalKey<FormState>? formKey;
  final Function(Function)? onRegisterSave;
  final Color themeColor;
  
  const DashboardEmailVerification({
    super.key, 
    required this.onComplete,
    this.formKey,
    this.onRegisterSave,
    this.themeColor = Colors.blue, // Default to blue if not provided
  });

  @override
  ConsumerState<DashboardEmailVerification> createState() => _DashboardEmailVerificationState();
}

class _DashboardEmailVerificationState extends ConsumerState<DashboardEmailVerification> {
  bool _isResending = false;
  Timer? _resendTimer;
  int _remainingSeconds = 0; // Start with 0 so button is enabled initially
  bool _isVerified = false;
  String? _email;
  
  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadSavedData();
    _checkVerificationStatus();
    
    // Check if we need to start the timer when the widget loads
    _checkAndStartTimer();
    
    // Register save callback
    if (widget.onRegisterSave != null) {
      widget.onRegisterSave!(_saveFormData);
    }
  }
  
  // Check if we need to show the timer based on saved data
  Future<void> _checkAndStartTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final lastEmailSentTime = prefs.getInt('last_verification_email_sent');
    
    if (lastEmailSentTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedSeconds = (now - lastEmailSentTime) ~/ 1000;
      
      // If less than 60 seconds have passed, start timer with remaining time
      if (elapsedSeconds < 60) {
        setState(() {
          _remainingSeconds = 60 - elapsedSeconds;
        });
        // Start the timer
        _startResendTimer();
      }
    }
  }

  @override
  void dispose() {
    // Cancel timer when widget is disposed
    _resendTimer?.cancel();
    super.dispose();
  }
  
  void _startResendTimer() {
    // Cancel any existing timer
    _resendTimer?.cancel();
    
    // Create a new timer that fires every second
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Only update if mounted to avoid setState after dispose
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
            print('Timer tick: $_remainingSeconds seconds remaining'); // Debug output
          } else {
            timer.cancel();
          }
        });
      }
    });
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

  Future<void> _checkVerificationStatus() async {
    final dashboardStatsAsync = ref.read(dashboardStatsProvider);
    dashboardStatsAsync.whenData((stats) {
      if (mounted) {
        setState(() {
          _isVerified = stats.isEmailVerified;
          
          // Save to form data for persistence
          final currentData = ref.read(profileFormDataProvider);
          ref.read(profileFormDataProvider.notifier).state = {
            ...currentData,
            'emailVerified': _isVerified,
          };
        });
      }
    });
  }
  
  Future<void> _resendVerificationEmail() async {
    if (_remainingSeconds > 0) return;
    
    setState(() {
      _isResending = true;
    });
    
    try {
      print('Attempting to resend verification email...');
      // Call the API to resend verification email
      final result = await ref.read(dashboardServiceProvider).requestEmailVerification();
      
      print('Email verification response: $result');
      
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        
        ToastService.show(
          context,
          result['message'] ?? 'Verification email sent to ${_email ?? "your email address"}',
          type: result['success'] ? ToastType.success : ToastType.error,
        );
        
        if (result['success']) {
          _startResendTimer();
          _saveEmailSentTime();
        }
      }
    } catch (e, stackTrace) {
      print('Error requesting email verification: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        
        ToastService.show(
          context,
          'Failed to send verification email: ${e.toString()}',
          type: ToastType.error,
        );
      }
    }
  }

  // Save the time when an email was sent
  Future<void> _saveEmailSentTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_verification_email_sent', DateTime.now().millisecondsSinceEpoch);
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
  
  // Method to refresh verification status
  Future<void> _refreshVerificationStatus() async {
    try {
      // Invalidate the provider to force a refresh
      ref.invalidate(dashboardStatsProvider);
      // Wait for the new data
      final stats = await ref.read(dashboardStatsProvider.future);
      
      if (mounted) {
        setState(() {
          _isVerified = stats.isEmailVerified;
        });
        
        // Save to form data for persistence
        _saveFormData();
        
        // If verified, show success message
        if (stats.isEmailVerified) {
          ToastService.show(
            context,
            'Email has been verified successfully!',
            type: ToastType.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService.show(
          context,
          'Failed to refresh verification status: ${e.toString()}',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);
    
    return Form(
      key: widget.formKey,
      child: dashboardStatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading verification status: ${error.toString()}',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
        data: (stats) {
          // Set verified status from API response
          if (_isVerified != stats.isEmailVerified) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _isVerified = stats.isEmailVerified;
              });
            });
          }
          
          return RefreshIndicator(
            onRefresh: _refreshVerificationStatus,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              // Ensure the scroll view has enough height to enable pull-to-refresh
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 200,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_isVerified) ...[
                      //Animation
                      SizedBox(
                        height: 200,
                        child: Lottie.asset(
                          'assets/animations/email_verfication.json',
                          animate: true,
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
                        color: _isVerified ? Colors.green : widget.themeColor,
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
                      // Resend email button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _remainingSeconds > 0 || _isResending
                              ? null
                              : _resendVerificationEmail,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: widget.themeColor),
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
                                        : widget.themeColor,
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
            ),
          );
        },
      ),
    );
  }
}