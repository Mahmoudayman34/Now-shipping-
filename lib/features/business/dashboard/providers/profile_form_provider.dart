import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to store form completion data
final profileFormDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});

/// Provider to track the current step in the form
final currentStepProvider = StateProvider<int>((ref) => 0);

/// Provider to track if the form has been submitted
final formSubmittedProvider = StateProvider<bool>((ref) => false);

/// Provider to track form controllers for each step to persist data
final formControllersProvider = Provider<Map<String, dynamic>>((ref) => {});

/// Provider to track required fields and their step numbers
final requiredFieldsProvider = Provider<Map<String, int>>((ref) {
  return {
    'emailVerified': 0,      // Email step
    'brandName': 1,          // Brand info step
    'industry': 1,
    'addressLine1': 2,       // Pickup address step
    'city': 2,
    'country': 2,
    'paymentMethod': 3,      // Payment method step
    'brandType': 4,          // Brand type step (final step)
  };
});