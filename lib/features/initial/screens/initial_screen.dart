import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/app_state_provider.dart';
import '../../onboarding/controller/onboarding_controller.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/signup_screen.dart';
import '../../business/home/screens/home_container.dart';
import '../../auth/services/auth_service.dart';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen> {
  bool _isLoading = true;
  bool _onboardingSeen = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    try {
      // Check if onboarding has been seen
      final onboardingController = OnboardingController();
      final onboardingSeen = await onboardingController.isOnboardingSeen();
      
      // Check if user is logged in
      final authService = ref.read(authServiceProvider);
      final isLoggedIn = await authService.isLoggedIn();
      
      // Update app state based on checks
      if (!onboardingSeen) {
        ref.read(appStateProvider.notifier).state = AppState.onboarding;
      } else if (isLoggedIn) {
        ref.read(appStateProvider.notifier).state = AppState.dashboard;
      } else {
        ref.read(appStateProvider.notifier).state = AppState.login;
      }
      
      setState(() {
        _onboardingSeen = onboardingSeen;
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      // Handle errors and default to login screen
      debugPrint('Error during app initialization: $e');
      ref.read(appStateProvider.notifier).state = AppState.login;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking app state
    if (_isLoading) {
      return _buildLoadingScreen();
    }
    
    // Get current app state
    final appState = ref.watch(appStateProvider);
    
    // Return the appropriate screen based on app state
    switch (appState) {
      case AppState.onboarding:
        return const OnboardingScreen();
      case AppState.login:
        return const LoginScreen();
      case AppState.signup:
        return const SignupScreen();
      case AppState.dashboard:
        return const HomeContainer();
      default:
        return const LoginScreen(); // Default to login screen
    }
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}