import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_form_provider.dart';
import 'package:tes1/core/widgets/toast_.dart' show ToastService, ToastType;
import '../../../auth/services/auth_service.dart';
import 'package:tes1/data/services/api_service.dart';
import '../models/profile_completion_model.dart';

/// A helper class to manage the profile completion form operations
class ProfileFormManager {
  final WidgetRef ref;
  final BuildContext context;
  late final ApiService _apiService;
  late final AuthService _authService;

  ProfileFormManager(this.ref, this.context) {
    _apiService = ApiService();
    _authService = ref.read(authServiceProvider);
  }

  /// Validates all required fields and returns missing fields
  /// Returns a map of field names to step numbers for missing fields
  Map<String, int> validateRequiredFields() {
    final formData = ref.read(profileFormDataProvider);
    final requiredFields = ref.read(requiredFieldsProvider);
    final missingFields = <String, int>{};

    // Debug log
    debugPrint('Validating form data: ${formData.keys}');

    for (final field in requiredFields.entries) {
      final fieldName = field.key;
      final stepNumber = field.value;
      bool isFieldPresent = false;

      // Special case handling for fields with alternative names
      switch (fieldName) {
        case 'sellingChannels':
          isFieldPresent = (formData.containsKey('channels') && formData['channels'] is List && (formData['channels'] as List).isNotEmpty) || 
                          (formData.containsKey('sellingChannels') && formData['sellingChannels'] is List && (formData['sellingChannels'] as List).isNotEmpty);
          break;
        
        case 'socialLinks':
          isFieldPresent = (formData.containsKey('socialLinks') && formData['socialLinks'] is List && (formData['socialLinks'] as List).isNotEmpty) ||
                          (formData.containsKey('channelLinks') && formData['channelLinks'] is Map && (formData['channelLinks'] as Map).isNotEmpty);
          break;
        
        case 'addressDetails':
          isFieldPresent = (formData.containsKey('addressDetails') && formData['addressDetails'] != null && formData['addressDetails'].toString().isNotEmpty) ||
                          (formData.containsKey('addressLine1') && formData['addressLine1'] != null && formData['addressLine1'].toString().isNotEmpty);
          break;
          
        case 'monthlyOrders':
          isFieldPresent = (formData.containsKey('monthlyOrders') && formData['monthlyOrders'] != null && formData['monthlyOrders'].toString().isNotEmpty) ||
                          (formData.containsKey('volume') && formData['volume'] != null && formData['volume'].toString().isNotEmpty);
          break;
          
        case 'city':
          isFieldPresent = (formData.containsKey('city') && formData['city'] != null && formData['city'].toString().isNotEmpty) ||
                          (formData.containsKey('region') && formData['region'] != null && formData['region'].toString().isNotEmpty);
          break;
          
        case 'documentPhotos':
          isFieldPresent = (formData.containsKey('documentPhotos') && formData['documentPhotos'] is List && (formData['documentPhotos'] as List).isNotEmpty) ||
                          (formData.containsKey('uploadedDocuments') && formData['uploadedDocuments'] is List && (formData['uploadedDocuments'] as List).isNotEmpty);
          break;

        // Payment method specific fields
        case 'ipaAddress':
          if (formData['paymentMethod'] == 'instapay') {
            isFieldPresent = formData.containsKey('ipaAddress') && formData['ipaAddress'] != null && formData['ipaAddress'].toString().isNotEmpty;
          } else {
            isFieldPresent = true; // Not required for other payment methods
          }
          break;

        case 'mobileNumber':
          if (formData['paymentMethod'] == 'wallet') {
            isFieldPresent = formData.containsKey('mobileNumber') && formData['mobileNumber'] != null && formData['mobileNumber'].toString().isNotEmpty;
          } else {
            isFieldPresent = true; // Not required for other payment methods
          }
          break;

        case 'iban':
          if (formData['paymentMethod'] == 'bank') {
            isFieldPresent = formData.containsKey('iban') && formData['iban'] != null && formData['iban'].toString().isNotEmpty;
          } else {
            isFieldPresent = true; // Not required for other payment methods
          }
          break;

        case 'accountName':
          if (formData['paymentMethod'] == 'bank') {
            isFieldPresent = formData.containsKey('accountName') && formData['accountName'] != null && formData['accountName'].toString().isNotEmpty;
          } else {
            isFieldPresent = true; // Not required for other payment methods
          }
          break;

        case 'bankName':
          if (formData['paymentMethod'] == 'bank') {
            isFieldPresent = formData.containsKey('bankName') && formData['bankName'] != null && formData['bankName'].toString().isNotEmpty;
          } else {
            isFieldPresent = true; // Not required for other payment methods
          }
          break;
          
        // Brand type specific fields
        case 'nationalIdNumber':
          if (formData['brandType'] == 'individual' || formData['brandType'] == 'personal') {
            isFieldPresent = formData.containsKey('nationalIdNumber') && formData['nationalIdNumber'] != null && formData['nationalIdNumber'].toString().isNotEmpty;
          } else {
            isFieldPresent = true; // Not required for company
          }
          break;
          
        case 'taxNumber':
          if (formData['brandType'] == 'company') {
            isFieldPresent = formData.containsKey('taxNumber') && formData['taxNumber'] != null && formData['taxNumber'].toString().isNotEmpty;
          } else {
            isFieldPresent = true; // Not required for personal
          }
          break;
          
        // Default case for standard fields
        default:
          isFieldPresent = formData.containsKey(fieldName) && 
                          formData[fieldName] != null && 
                          (formData[fieldName] is! String || (formData[fieldName] as String).isNotEmpty);
          break;
      }

      if (!isFieldPresent) {
        debugPrint('Missing field: $fieldName for step: $stepNumber');
        missingFields[fieldName] = stepNumber;
      }
    }

    // If any fields are missing, log them for debugging
    if (missingFields.isNotEmpty) {
      debugPrint('Missing fields detected: ${missingFields.keys.join(", ")}');
    } else {
      debugPrint('All required fields are present');
    }

    return missingFields;
  }

  /// Complete user profile and save data to backend
  Future<bool> completeProfile() async {
    try {
      // Get current user
      final user = await _authService.getCurrentUser();
      
      if (user != null) {
        // Get all collected form data
        final wizardData = ref.read(profileFormDataProvider);
        
        // Debug log form data before sending
        debugPrint('Submitting profile data with keys: ${wizardData.keys.join(', ')}');
        
        // Create the profile completion model from form data
        final profileData = ProfileCompletionModel.fromFormData(wizardData);

        // Get auth token
        final token = await _authService.getToken();
        if (token == null) {
          ToastService.show(
            context,
            'Authentication error: No token found',
            type: ToastType.error,
          );
          return false;
        }
        
        // Send profile data to backend API
        final response = await _apiService.post(
          '/business/complete-confirmation-form',
          body: profileData.toJson(),
          token: token,
        );
        
        // Log response for debugging
        debugPrint('Profile completion API response: $response');

        // Mark profile as complete in local user model
        await _authService.completeProfile(user);
        
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
        final errorFieldNames = missingFields.keys
            .where((key) => missingFields[key] == firstMissingStep)
            .toList();
        
        if (errorFieldNames.isNotEmpty) {
          final stepName = stepLabels[firstMissingStep];
          ToastService.show(
            context,
            'Please complete all required fields in the $stepName step.\n'
            'Missing: ${errorFieldNames.join(", ")}',
            type: ToastType.warning,
            duration: const Duration(seconds: 4),
          );
        }
      });
    }
  }
}