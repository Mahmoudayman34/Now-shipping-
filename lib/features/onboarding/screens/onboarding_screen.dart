import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/onboarding_page.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_page_widget.dart';
import '../../../core/state/app_state_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    ref.read(onboardingProvider.notifier).setCurrentPage(page);
  }

  void _previousPage() {
    final currentPage = _pageController.page ?? 0;
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    final currentPage = _pageController.page ?? 0;
    if (currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (!mounted) return;
    ref.read(appStateProvider.notifier).state = AppState.login;
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final currentPage = onboardingState.currentPage;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isLastPage = currentPage == onboardingPages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: onboardingPages.length,
            itemBuilder: (context, index) {
              return OnboardingPageWidget(
                pageData: onboardingPages[index],
              );
            },
          ),
          // Navigation Controls
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 24 : 40),
              child: Column(
                children: [
                  // Top Navigation (Back Button)
                  if (currentPage > 0)
                    Align(
                      alignment: Alignment.topLeft,
                      child: _buildNavigationButton(
                        icon: Icons.arrow_back_ios,
                        onPressed: _previousPage,
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  const Spacer(),
                  // Page Indicator
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: onboardingPages.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Colors.white,
                        dotColor: Colors.white.withOpacity(0.4),
                        dotHeight: isSmallScreen ? 8 : 10,
                        dotWidth: isSmallScreen ? 8 : 10,
                        expansionFactor: 3,
                        spacing: 8,
                      ),
                    ),
                  ),
                  // Bottom Navigation (Next/Get Started Button)
                  if (!isLastPage)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: _buildNavigationButton(
                        icon: Icons.arrow_forward_ios,
                        onPressed: _nextPage,
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  // Get Started Button (Last Page)
                  if (isLastPage)
                    _buildGetStartedButton(isSmallScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isSmallScreen,
  }) {
    return Container(
      width: isSmallScreen ? 50 : 60,
      height: isSmallScreen ? 50 : 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Icon(
            icon,
            color: const Color(0xFFF29620),
            size: isSmallScreen ? 20 : 24,
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(bool isSmallScreen) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 32 : 40,
            vertical: isSmallScreen ? 16 : 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _completeOnboarding,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Get Started',
                  style: GoogleFonts.manrope(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
