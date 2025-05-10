import 'package:flutter/material.dart';
import '../data/onboarding_items.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/onboarding_dots_indicator.dart';
import '../widgets/onboarding_navigation_buttons.dart';
import '../../auth/screens/login_screen.dart';
import '../controller/onboarding_controller.dart';
import '../../../core/utils/responsive.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  void _nextPage() {
    if (_currentIndex < onboardingItems.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  void _finish() async {
    final controller = OnboardingController();
    await controller.markOnboardingSeen();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsivePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogo(),
              const SizedBox(height: 12),
              _buildPageView(),
              const SizedBox(height: 20),
              _buildDotsIndicator(),
              const SizedBox(height: 24),
              _buildNavigationButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 12.0),
      child: Image.asset(
        'assets/images/app_inside_logo.png',
        height: 45,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView.builder(
        controller: _controller,
        itemCount: onboardingItems.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (_, index) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: OnboardingPage(
            key: ValueKey(index),
            item: onboardingItems[index],
          ),
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Center(
      child: OnboardingDotsIndicator(
        currentIndex: _currentIndex,
        itemCount: onboardingItems.length,
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: OnboardingNavigationButtons(
        onSkip: _skip,
        onNext: _nextPage,
        currentIndex: _currentIndex,
        totalItems: onboardingItems.length,
      ),
    );
  }
}
