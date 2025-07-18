import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/core/widgets/toast_.dart' show ToastService, ToastType;
import 'package:now_shipping/features/business/home/screens/home_container.dart';
import '../../../auth/services/auth_service.dart';
import 'email_verification_step.dart';
import 'brand_info_step.dart';
import 'pickup_address_step.dart';
import 'payment_method_step.dart';
import 'brand_type_step.dart';
import 'congrats_step.dart';
import 'progress_bar.dart';
import '../providers/profile_form_provider.dart';
import '../services/profile_form_manager.dart';

class ProfileCompletionForm extends ConsumerStatefulWidget {
  const ProfileCompletionForm({super.key});
  
  @override
  ConsumerState<ProfileCompletionForm> createState() => _ProfileCompletionFormState();
}

class _ProfileCompletionFormState extends ConsumerState<ProfileCompletionForm> {
  final PageController _pageController = PageController();
  // Main form has 5 steps (last step is congrats which is only shown after submission)
  final int _totalSteps = 5;
  bool _isSubmitting = false;
  
  // Define theme color to match progress bar
  static const Color themeColor = Color(0xfff29620);
  
  // Step labels for the progress bar and validation messages
  final List<String> stepLabels = [
    "Email",
    "Brand",
    "Pickup",
    "Payment",
    "Type",
  ];
  
  // Create global keys for each form step to access their state
  final List<GlobalKey<FormState>> _formKeys = List.generate(
    5, // Number of form steps (excluding congrats)
    (_) => GlobalKey<FormState>(),
  );
  
  // References to step controllers to trigger saves
  final List<Function?> _saveCallbacks = List.generate(5, (_) => null);

  // Store the current step for cleanup operations
  late int _lastKnownStep;
  
  // Form manager instance
  late ProfileFormManager _formManager;
  
  @override
  void initState() {
    super.initState();
    // Initialize last known step
    _lastKnownStep = 0;
    
    // Listen to page changes and update the provider
    _pageController.addListener(_handlePageChange);
    
    // Try to restore any previously saved data from local storage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize form manager
    _formManager = ProfileFormManager(ref, context);
  }
  
  void _handlePageChange() {
    if (_pageController.page != null) {
      final currentPage = _pageController.page!.round();
      
      // If page changed, save data from the previous page
      if (currentPage != ref.read(currentStepProvider)) {
        // Get the previous page index
        final previousPage = ref.read(currentStepProvider);
        _lastKnownStep = previousPage; // Store the last known step
        
        // Trigger save on the previous step before changing pages
        _saveCurrentStepData(previousPage);
        
        // Update current step provider
        ref.read(currentStepProvider.notifier).state = currentPage;
      }
    }
  }

  // Save data for the current step
  void _saveCurrentStepData(int stepIndex) {
    // Only try to save if we have a valid index and a save callback for this step
    if (stepIndex >= 0 && stepIndex < _saveCallbacks.length && _saveCallbacks[stepIndex] != null) {
      _saveCallbacks[stepIndex]!();
    }
  }
  
  // Load any previously saved data
  Future<void> _loadSavedData() async {
    // In a real app, you would fetch data from SharedPreferences or your backend
    debugPrint('Loading any saved profile data...');
  }

  @override
  void dispose() {
    // Remove page controller listener
    _pageController.removeListener(_handlePageChange);
    
    // Safely clean up
    try {
      // Save any pending data but in a safer way
      if (_lastKnownStep >= 0 && _lastKnownStep < _saveCallbacks.length && 
          _saveCallbacks[_lastKnownStep] != null) {
        // Since we're being disposed, call this in a try-catch to prevent crashes
        try {
          _saveCallbacks[_lastKnownStep]!();
        } catch (e) {
          debugPrint('Error during save callback in dispose: $e');
        }
      }
    } catch (e) {
      debugPrint('Error during disposal cleanup: $e');
    }
    
    _pageController.dispose();
    super.dispose();
  }
  
  // Register a save callback for a specific step
  void registerSaveCallback(int stepIndex, Function saveCallback) {
    if (stepIndex >= 0 && stepIndex < _saveCallbacks.length) {
      _saveCallbacks[stepIndex] = saveCallback;
    }
  }
  
  // Navigate to a specific step by index
  void goToStep(int stepIndex) {
    // Prevent going to the congrats step directly
    if (stepIndex >= _totalSteps) return;
    
    if (stepIndex >= 0 && stepIndex < _totalSteps) {
      // Save current step data before navigating
      _saveCurrentStepData(ref.read(currentStepProvider));
      
      _pageController.animateToPage(
        stepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToNextStep() {
    final currentStep = ref.read(currentStepProvider);
    // Save current step data before navigating
    _saveCurrentStepData(currentStep);
    
    if (currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (currentStep == _totalSteps - 1) {
      // This is the final form step (Brand Type), mark profile as complete
      // and navigate to congrats page
      _completeProfile();
    } else {
      // This is already the congrats step, finish the form
      _finishForm();
    }
  }

  void goToPreviousStep() {
    // Save current step data before navigating back
    _saveCurrentStepData(ref.read(currentStepProvider));
    
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  // Finish the entire form process
  void _finishForm() {
    // Handle final completion, e.g., navigate to dashboard
    debugPrint('Form completed, navigating to home');
    
    // Navigate to HomeContainer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeContainer()),
    );
  }
  
  Future<void> _completeProfile() async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
        )
      ),
    );

    try {
      final success = await _formManager.completeProfile();
      
      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);
        
        setState(() {
          _isSubmitting = false;
        });
        
        if (success) {
          // Navigate to HomeContainer
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeContainer()),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
        
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return _buildFormContent();
  }
  
  Widget _buildFormContent() {
    final currentStep = ref.watch(currentStepProvider);
    final isFormSubmitted = ref.watch(formSubmittedProvider);
    
    // Determine what steps to show in the progress bar
    // If the form is submitted, we want to show the congracts step in the bar
    // otherwise, just show the regular form steps
    final displayCurrentStep = isFormSubmitted && currentStep >= _totalSteps 
        ? _totalSteps // Show the last step indicator for congrats
        : currentStep + 1; // Regular step indicator
    
    return Column(
      children: [
        // Progress bar - only show if not on congrats screen or if submitted
        if (!isFormSubmitted || currentStep < _totalSteps)
          ProgressBar(
            currentStep: displayCurrentStep,
            totalSteps: _totalSteps,
            stepLabels: stepLabels,
            onStepTap: goToStep,
          ),
        
        // Form content
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              // If trying to navigate to congrats step but form not submitted, 
              // go back to last form step
              if (index >= _totalSteps && !ref.read(formSubmittedProvider)) {
                _pageController.animateToPage(
                  _totalSteps - 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                return;
              }
              
              ref.read(currentStepProvider.notifier).state = index;
            },
            children: _buildFormSteps(),
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildFormSteps() {
    return [
      // Step 1: Email verification
      DashboardEmailVerification(
        onComplete: goToNextStep,
        formKey: _formKeys[0],
        onRegisterSave: (saveCallback) => registerSaveCallback(0, saveCallback),
        themeColor: themeColor,
      ),
      // Step 2: Brand info
      DashboardBrandInfoStep(
        onComplete: goToNextStep, 
        onPrevious: goToPreviousStep,
        formKey: _formKeys[1],
        onRegisterSave: (saveCallback) => registerSaveCallback(1, saveCallback),
        themeColor: themeColor,
      ),
      // Step 3: Pickup address
      DashboardPickupAddressStep(
        onComplete: goToNextStep, 
        onPrevious: goToPreviousStep,
        formKey: _formKeys[2],
        onRegisterSave: (saveCallback) => registerSaveCallback(2, saveCallback),
        themeColor: themeColor,
      ),
      // Step 4: Payment method
      DashboardPaymentMethodStep(
        onComplete: goToNextStep, 
        onPrevious: goToPreviousStep,
        formKey: _formKeys[3],
        onRegisterSave: (saveCallback) => registerSaveCallback(3, saveCallback),
        themeColor: themeColor,
      ),
      // Step 5: Brand type (last form step)
      DashboardBrandTypeStep(
        onComplete: goToNextStep, 
        onPrevious: goToPreviousStep,
        formKey: _formKeys[4],
        onRegisterSave: (saveCallback) => registerSaveCallback(4, saveCallback),
        validateAndSubmit: _validateAndSubmit,
        themeColor: themeColor,
      ),
      // Congrats step (shown after form submission)
      DashboardCongratsStep(
        onComplete: _finishForm,
        themeColor: themeColor,
      ),
    ];
  }
  
  // Validation method to pass to the last step
  void _validateAndSubmit() {
    // Use the form manager to validate and submit
    final currentStep = ref.read(currentStepProvider);
    
    // Make sure current step data is saved before validation
    _saveCurrentStepData(currentStep);
    
    _formManager.validateAndSubmit(
      currentStep: currentStep,
      onSuccess: _completeProfile,
      goToStep: goToStep,
      stepLabels: stepLabels,
    );
  }
}
