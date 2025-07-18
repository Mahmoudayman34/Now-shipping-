import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:now_shipping/features/business/dashboard/providers/profile_form_provider.dart';
import 'profile_completion_form.dart';

class DashboardCongratsStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final Color themeColor;
  
  const DashboardCongratsStep({
    super.key, 
    required this.onComplete,
    this.themeColor = Colors.blue, // Default to blue if not provided
  });

  @override
  ConsumerState<DashboardCongratsStep> createState() => _DashboardCongratsStepState();
}

class _DashboardCongratsStepState extends ConsumerState<DashboardCongratsStep> {
  @override
  void initState() {
    super.initState();
    // Automatically start the completion animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
    });
  }
  
  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _showAnimation = true;
    });
  }
  
  bool _showAnimation = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileData = ref.watch(profileFormDataProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success animation
          SizedBox(
            height: 200,
            child: Center(
              child: Lottie.asset(
                'assets/animations/success.json',
                animate: _showAnimation,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Congratulations text
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
              children: [
                Text(
                  "You're all set!",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.themeColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  "Your profile has been completed successfully. You can now fully use all features of the app.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Profile summary section
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile Summary",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Display summary info
                  _buildSummaryRow(
                    icon: Icons.business,
                    label: "Brand",
                    value: profileData['brandName'] as String? ?? 'Not provided',
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildSummaryRow(
                    icon: Icons.category,
                    label: "Industry",
                    value: profileData['industry'] as String? ?? 'Not provided',
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildSummaryRow(
                    icon: Icons.location_on,
                    label: "Location",
                    value: "${profileData['city'] ?? 'City'}, ${profileData['country'] ?? 'Country'}",
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildSummaryRow(
                    icon: Icons.payments,
                    label: "Payment",
                    value: _getPaymentMethodName(profileData['paymentMethod'] as String? ?? ''),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Finish button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Finish Setup",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  String _getPaymentMethodName(String id) {
    switch (id) {
      case 'cash':
        return 'Cash on Delivery';
      case 'bank':
        return 'Bank Transfer';
      case 'wallet':
        return 'Digital Wallet';
      default:
        return 'Not selected';
    }
  }
  
  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}