import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
/// Provider to manage refresh functionality for each screen
final screenRefreshProvider = StateProvider<Map<int, VoidCallback?>>((ref) => {});

/// Mixin that provides refresh functionality for screens in the main layout
mixin RefreshableScreenMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // Store the provider notifier to avoid using ref during dispose
  StateController<Map<int, VoidCallback?>>? _refreshProviderNotifier;
  
  /// Register a refresh callback for this screen
  void registerRefreshCallback(VoidCallback refreshCallback, int screenIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Store the notifier reference for safe disposal
      _refreshProviderNotifier ??= ref.read(screenRefreshProvider.notifier);
      
      final refreshCallbacks = ref.read(screenRefreshProvider);
      final updatedCallbacks = Map<int, VoidCallback?>.from(refreshCallbacks);
      updatedCallbacks[screenIndex] = refreshCallback;
      _refreshProviderNotifier!.state = updatedCallbacks;
    });
  }
  
  /// Unregister refresh callback when screen is disposed
  void unregisterRefreshCallback(int screenIndex) {
    // Use Future.microtask to delay the provider modification until after the widget tree is done building
    Future.microtask(() {
      if (_refreshProviderNotifier != null) {
        final refreshCallbacks = _refreshProviderNotifier!.state;
        final updatedCallbacks = Map<int, VoidCallback?>.from(refreshCallbacks);
        updatedCallbacks.remove(screenIndex);
        _refreshProviderNotifier!.state = updatedCallbacks;
      }
    });
  }
}
