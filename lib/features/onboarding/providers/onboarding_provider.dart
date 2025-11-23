import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState {
  final bool hasSeenOnboarding;
  final int currentPage;

  const OnboardingState({
    this.hasSeenOnboarding = false,
    this.currentPage = 0,
  });

  OnboardingState copyWith({
    bool? hasSeenOnboarding,
    int? currentPage,
  }) {
    return OnboardingState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState()) {
    _loadOnboardingStatus();
  }

  static const String _key = 'has_seen_onboarding';
  final Completer<void> _loadCompleter = Completer<void>();

  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool(_key) ?? false;
      state = state.copyWith(hasSeenOnboarding: hasSeen);
    } catch (e) {
      // Handle error silently, default to false
      state = const OnboardingState();
    } finally {
      if (!_loadCompleter.isCompleted) {
        _loadCompleter.complete();
      }
    }
  }

  /// Ensures the onboarding status is loaded before reading
  Future<void> ensureLoaded() async {
    if (!_loadCompleter.isCompleted) {
      await _loadCompleter.future;
    }
  }

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
      state = state.copyWith(hasSeenOnboarding: true);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, false);
      state = const OnboardingState();
    } catch (e) {
      // Handle error silently
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

