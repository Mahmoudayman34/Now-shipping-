import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// App state provider to manage global app state
final appStateProvider = StateProvider<AppState>((ref) => AppState.initial);

// Enum to represent different app states
enum AppState {
  initial,
  onboarding,
  login,
  signup,
  dashboard,
}