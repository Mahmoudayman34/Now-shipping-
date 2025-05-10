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
    'monthlyOrders': 1,
    'sellingChannels': 1,    // At least one selling channel required
    'socialLinks': 1,        // Social links
    
    'country': 2,            // Pickup address step
    'city': 2,
    'addressDetails': 2,     // Address details
    
    'paymentMethod': 3,      // Payment method step
    
    // Conditional fields based on payment method
    // These are handled in validation logic:
    // - ipaAddress: required if paymentMethod is instapay
    // - mobileNumber: required if paymentMethod is wallet
    // - bankName: required if paymentMethod is bank
    // - iban: required if paymentMethod is bank
    // - accountName: required if paymentMethod is bank
    
    'brandType': 4,          // Brand type step (final step)
    'documentPhotos': 4,     // Photos of brand type (ID or company papers)
    
    // Conditional fields based on brand type
    // These are handled in validation logic:
    // - nationalIdNumber: required if brandType is personal
    // - taxNumber: required if brandType is company
  };
});