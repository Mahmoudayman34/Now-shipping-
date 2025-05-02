import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_form_provider.dart';
import 'package:tes1/core/widgets/toast_.dart' show ToastService, ToastType;
import '../../../auth/services/auth_service.dart';

/// A helper class to manage the profile completion form operations
class ProfileFormManager {
  final WidgetRef ref;
  final BuildContext context;

  ProfileFormManager(this.ref, this.context);

  /// Validates all required fields and returns missing fields
  /// Returns a map of field names to step numbers for missing fields
  Map<String, int> validateRequiredFields() {
    final formData = ref.read(profileFormDataProvider);
    final requiredFields = ref.read(requiredFieldsProvider);
    final missingFields = <String, int>{};

    for (final field in requiredFields.entries) {
      if (!formData.containsKey(field.key) || formData[field.key] == null || 
          (formData[field.key] is String && (formData[field.key] as String).isEmpty)) {
        missingFields[field.key] = field.value;
      }
    }

    return missingFields;
  }

  /// Complete user profile and save data to backend
  Future<bool> completeProfile() async {
    try {
      // Get current user
      final user = await ref.read(authServiceProvider).getCurrentUser();
      
      if (user != null) {
        // Get all collected data
        final wizardData = ref.read(profileFormDataProvider);
        
        // In a real app, you would send this data to your backend
        debugPrint('Completing profile with data: $wizardData');
        
        // Mark profile as complete
        await ref.read(authServiceProvider).completeProfile(user);
        
        // Refresh the user provider
        // ignore: unused_result
        ref.refresh(currentUserProvider);
        
        // Mark the form as submitted
        ref.read(formSubmittedProvider.notifier).state = true;
        
        // Show success message
        ToastService.show(
          context,
          'Profile completed successfully!',
          type: ToastType.success,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      // Show error
      ToastService.show(
        context,
        'Error completing profile: $e',
        type: ToastType.error,
      );
      return false;
    }
  }
  
  /// Validate the form and show appropriate errors
  /// [onSuccess] is called when validation passes
  /// [currentStep] is the current step index
  /// [goToStep] is a function to navigate to a specific step
  void validateAndSubmit({
    required int currentStep,
    required Function() onSuccess,
    required Function(int) goToStep,
    required List<String> stepLabels,
  }) {
    // Check for missing required fields
    final missingFields = validateRequiredFields();
    
    if (missingFields.isEmpty) {
      // All required fields are filled, proceed to completion
      onSuccess();
    } else {
      // Navigate to the step with the first missing field
      final firstMissingStep = missingFields.values.first;
      goToStep(firstMissingStep);
      
      // Show focused error message on the current step they're navigated to
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Get the name of the step they were sent to
        final stepName = firstMissingStep < stepLabels.length 
            ? stepLabels[firstMissingStep]
            : 'this step';
        
        // Show toast with error message
        ToastService.show(
          context,
          'Please complete the required fields in $stepName',
          type: ToastType.warning,
          onUndo: null,
        );
      });
    }
  }
}