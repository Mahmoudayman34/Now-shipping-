import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that monitors connectivity status
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  
  // Check initial connectivity status
  final initialResult = await connectivity.checkConnectivity();
  yield initialResult.contains(ConnectivityResult.mobile) ||
         initialResult.contains(ConnectivityResult.wifi) ||
         initialResult.contains(ConnectivityResult.ethernet);
  
  // Listen to connectivity changes
  yield* connectivity.onConnectivityChanged.map((result) {
    // Check if we have any active connection
    return result.contains(ConnectivityResult.mobile) ||
           result.contains(ConnectivityResult.wifi) ||
           result.contains(ConnectivityResult.ethernet);
  });
});

/// Provider that provides the current connectivity status as a boolean
final isConnectedProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  
  return connectivityAsync.when(
    data: (isConnected) => isConnected,
    loading: () => true, // Assume connected while loading
    error: (_, __) => false, // Assume disconnected on error
  );
});

