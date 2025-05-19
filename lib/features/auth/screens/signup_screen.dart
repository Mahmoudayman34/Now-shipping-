import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
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

class _SignupScreenState extends ConsumerState<SignupScreen> with TickerProviderStateMixin {
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
  
  // Animation controllers
  late final AnimationController _truckController;
  late final AnimationController _packageController;
  late final AnimationController _locationController;
  late final AnimationController _routeController;
  
  // Animations
  late final Animation<double> _truckAnimation;
  late final Animation<double> _packageAnimation;
  late final Animation<double> _locationAnimation;
  late final Animation<double> _routeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers with different durations
    _truckController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    
    _packageController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    
    _locationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    
    _routeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    
    // Create animations with curves
    _truckAnimation = Tween<double>(begin: -10.0, end: 10.0)
      .animate(CurvedAnimation(
        parent: _truckController, 
        curve: Curves.easeInOut,
      ));
    
    _packageAnimation = Tween<double>(begin: -8.0, end: 8.0)
      .animate(CurvedAnimation(
        parent: _packageController, 
        curve: Curves.easeInOut,
      ));
    
    _locationAnimation = Tween<double>(begin: -5.0, end: 5.0)
      .animate(CurvedAnimation(
        parent: _locationController, 
        curve: Curves.easeInOut,
      ));
    
    _routeAnimation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(
        parent: _routeController, 
        curve: Curves.linear,
      ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    
    _truckController.dispose();
    _packageController.dispose();
    _locationController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Shipping-themed background
            ...buildShippingBackgroundElements(),
            
            // Main content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                      const SizedBox(height: 24),
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
                  height: 90,
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
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'Fill in your details to get started',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Registration form
                      Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Form fields
                              _buildCustomTextField(
                                controller: _nameController, 
                                label: 'Full Name',
                                hintText: 'Enter your full name',
                                icon: Icons.person_outline,
                                validator: Validators.name,
                              ),
                              
                              const SizedBox(height: 20),
                              
                              _buildPhoneField(),
                              
                              const SizedBox(height: 20),
                              
                              _buildCustomTextField(
                                controller: _emailController, 
                                label: 'Email',
                                hintText: 'Enter your email address',
                                icon: Icons.email_outlined,
                                validator: Validators.email,
                              ),
                              
                              const SizedBox(height: 20),
                              
                              _buildCustomTextField(
                                controller: _passwordController, 
                                label: 'Password',
                                hintText: 'Create a password',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: Validators.password,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Checkboxes with better styling
              Theme(
                                data: Theme.of(context).copyWith(
                  checkboxTheme: CheckboxThemeData(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _wantsStorage,
                                            onChanged: (value) => setState(() => _wantsStorage = value ?? false),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            activeColor: const Color(0xFFFF9800),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                        "I want storage",
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _agreeToTerms,
                                            onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            activeColor: const Color(0xFFFF9800),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                        "I agree to the terms and conditions",
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                    ),
                  ],
                ),
              ),
      
              const SizedBox(height: 32),
      
                              // Submit button with gradient
              SizedBox(
                width: double.infinity,
                                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
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
                                                      color: Colors.transparent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                                          : const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                        ),
                ),
              ),
      
                      const SizedBox(height: 32),
                      
                      // Sign in link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                            child: const Text(
                            "Login",
                            style: TextStyle(
                                color: Color(0xFF3266A2),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
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
      
      // Simple route line with animation
      AnimatedBuilder(
        animation: _routeAnimation,
        builder: (context, child) {
          return Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: AnimatedRoutePainter(
                lineColor: Colors.grey.withOpacity(0.1),
                progress: _routeAnimation.value,
              ),
            ),
          );
        },
      ),
      
      // Delivery truck top-right - with animation
      AnimatedBuilder(
        animation: _truckAnimation,
        builder: (context, child) {
          return Positioned(
            top: 30 + _truckAnimation.value,
            right: 20,
            child: const Opacity(
              opacity: 0.07,
              child: Icon(
                Icons.local_shipping_outlined,
                size: 80,
                color: blueColor,
              ),
            ),
          );
        },
      ),
      
      // Package box top-left - with animation
      AnimatedBuilder(
        animation: _packageAnimation,
        builder: (context, child) {
          return Positioned(
            top: 120 + _packageAnimation.value,
            left: 20,
            child: const Opacity(
              opacity: 0.07,
              child: Icon(
                Icons.inventory_2_outlined,
                size: 60,
                color: orangeColor,
              ),
            ),
          );
        },
      ),
      
      // Location pin middle-right - with animation
      AnimatedBuilder(
        animation: _locationAnimation,
        builder: (context, child) {
          return Positioned(
            top: 250 + _locationAnimation.value,
            right: 40,
            child: const Opacity(
              opacity: 0.07,
              child: Icon(
                Icons.location_on_outlined,
                size: 70,
                color: blueColor,
              ),
            ),
          );
        },
      ),
      
      // Small package middle-left - with animation
      AnimatedBuilder(
        animation: _packageAnimation,
        builder: (context, child) {
          return Positioned(
            top: 320 - _packageAnimation.value,
            left: 30,
            child: const Opacity(
              opacity: 0.07,
              child: Icon(
                Icons.inventory_outlined,
                size: 50,
                color: orangeColor,
              ),
            ),
          );
        },
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
      
      // Bottom delivery truck - with animation
      AnimatedBuilder(
        animation: _truckAnimation,
        builder: (context, child) {
          return Positioned(
            bottom: 80 - _truckAnimation.value,
            right: 30,
            child: const Opacity(
              opacity: 0.07,
              child: Icon(
                Icons.local_shipping_outlined,
                size: 60,
                color: orangeColor,
              ),
            ),
          );
        },
      ),
      
      // Bottom package - with animation
      AnimatedBuilder(
        animation: _packageAnimation,
        builder: (context, child) {
          return Positioned(
            bottom: 30 - _packageAnimation.value,
            left: 40,
            child: const Opacity(
              opacity: 0.07,
              child: Icon(
                Icons.inventory_2_outlined,
                size: 50,
                color: blueColor,
              ),
            ),
          );
        },
      ),
    ];
  }

  // Custom text field builder with icon
  Widget _buildCustomTextField({
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
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
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

  // Phone field with verification
  Widget _buildPhoneField() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Phone Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ),
            Container(
              decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Phone number input
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !_isPhoneVerified,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                        hintText: 'Enter your phone number',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[600], size: 20),
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
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: _isPhoneVerified ? null : _verifyPhone,
                      style: ElevatedButton.styleFrom(
                    backgroundColor: _isPhoneVerified ? Colors.grey : const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                    elevation: 0,
                        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                        ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      : Text(
                          _isPhoneVerified ? 'Verified' : 'Verify',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ),
                  ),
                ],
              ),
            ),
            
            // OTP field that appears after clicking verify
            if (_showOtpField) ...[
              const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Verification Code',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Container(
                      decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
              style: const TextStyle(fontSize: 16, letterSpacing: 8),
              decoration: InputDecoration(
                          hintText: '6-digit code',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, letterSpacing: 2),
                prefixIcon: Icon(Icons.security_outlined, color: Colors.grey[600], size: 20),
                          border: InputBorder.none,
                          counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                        validator: (value) {
                          if (_showOtpField && (value == null || value.length < 6)) {
                            return 'Please enter the complete 6-digit OTP';
                          }
                          return null;
                        },
                      ),
                    ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _verifyPhone(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3266A2),
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Resend Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
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

// Animated route painter
class AnimatedRoutePainter extends CustomPainter {
  final Color lineColor;
  final double progress;
  
  AnimatedRoutePainter({required this.lineColor, required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    
    // Draw a shipping route with curves - start from top left and zigzag to bottom right
    path.moveTo(size.width * 0.1, size.height * 0.2);
    
    // First curve to mid-right
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.1,
      size.width * 0.8, size.height * 0.3,
    );
    
    // Second curve to mid-left
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.5,
      size.width * 0.2, size.height * 0.6,
    );
    
    // Third curve to bottom-right
    path.quadraticBezierTo(
      size.width * 0.1, size.height * 0.8,
      size.width * 0.7, size.height * 0.9,
    );
    
    // Create a path metrics object to measure the path
    final PathMetrics pathMetrics = path.computeMetrics();
    final PathMetric pathMetric = pathMetrics.first;
    
    // Extract a portion of the path based on animation progress
    final Path extractedPath = Path();
    extractedPath.addPath(
      pathMetric.extractPath(0, pathMetric.length * progress),
      Offset.zero,
    );
    
    // Draw the animated path
    canvas.drawPath(extractedPath, paint);
    
    // Add "traveling dot" at the end of the current path
    if (progress > 0.01) {
      final tangent = pathMetric.getTangentForOffset(pathMetric.length * progress);
      if (tangent != null) {
        final dotPaint = Paint()
          ..color = const Color(0xFFF89C29)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(tangent.position, 3.0, dotPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(AnimatedRoutePainter oldDelegate) => 
    oldDelegate.progress != progress;
}