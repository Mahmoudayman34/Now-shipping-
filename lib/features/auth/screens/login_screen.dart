import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/login_form.dart';
import '../../../core/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
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
            constraints: const BoxConstraints(maxWidth: 450),
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
                          height: 100,
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
                          AppLocalizations.of(context).welcomeBack,
                          style: const TextStyle(
                            fontSize: 32,
                        fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        AppLocalizations.of(context).loginToAccount,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Login form
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
                        child: const LoginForm(),
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
