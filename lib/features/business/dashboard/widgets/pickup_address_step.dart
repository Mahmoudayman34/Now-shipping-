import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import 'package:tes1/core/widgets/toast_.dart' show ToastService, ToastType;
import '../providers/profile_form_provider.dart';

class DashboardPickupAddressStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onPrevious;
  final GlobalKey<FormState>? formKey;
  final Function(Function)? onRegisterSave;
  
  const DashboardPickupAddressStep({
    super.key, 
    required this.onComplete,
    required this.onPrevious,
    this.formKey,
    this.onRegisterSave,
  });

  @override
  ConsumerState<DashboardPickupAddressStep> createState() => _DashboardPickupAddressStepState();
}

class _DashboardPickupAddressStepState extends ConsumerState<DashboardPickupAddressStep> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _addressDetailsController = TextEditingController();
  final TextEditingController _nearbyLandmarkController = TextEditingController();
  String? _selectedCountry;
  String? _selectedRegion;
  
  final List<String> countries = [
    'Egypt',
    'United Arab Emirates',
    'Saudi Arabia',
    'Jordan',
    'Kuwait',
    'Lebanon',
    'Qatar',
    'Bahrain',
    'Oman',
    'Other'
  ];

  final Map<String, List<String>> regionsByCountry = {
    'Egypt': ['Cairo', 'Alexandria', 'Giza', 'Luxor', 'Aswan', 'Other'],
    'United Arab Emirates': ['Dubai', 'Abu Dhabi', 'Sharjah', 'Ajman', 'Other'],
    'Saudi Arabia': ['Riyadh', 'Jeddah', 'Mecca', 'Medina', 'Other'],
    'Jordan': ['Amman', 'Zarqa', 'Irbid', 'Aqaba', 'Other'],
    'Kuwait': ['Kuwait City', 'Hawalli', 'Ahmadi', 'Farwaniya', 'Other'],
    'Lebanon': ['Beirut', 'Tripoli', 'Sidon', 'Tyre', 'Other'],
    'Qatar': ['Doha', 'Al Rayyan', 'Al Wakrah', 'Al Khor', 'Other'],
    'Bahrain': ['Manama', 'Riffa', 'Muharraq', 'Hamad Town', 'Other'],
    'Oman': ['Muscat', 'Salalah', 'Sohar', 'Nizwa', 'Other'],
    'Other': ['Other'],
  };
  
  @override
  void initState() {
    super.initState();
    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
    
    // Register save callback
    if (widget.onRegisterSave != null) {
      widget.onRegisterSave!(_saveFormData);
    }
  }
  
  @override
  void dispose() {
    _addressDetailsController.dispose();
    _nearbyLandmarkController.dispose();
    super.dispose();
  }

  // Method to save current form data without validation
  void _saveFormData() {
    // Save current state to provider even if incomplete
    final formData = {
      'addressLine1': _addressDetailsController.text,
      'nearbyLandmark': _nearbyLandmarkController.text,
      'country': _selectedCountry,
      'region': _selectedRegion,
      'city': _selectedRegion, // Make sure city is also set as it's required
    };
    
    try {
      // Update the provider
      final currentData = ref.read(profileFormDataProvider);
      ref.read(profileFormDataProvider.notifier).state = {
        ...currentData,
        ...formData,
      };
      
      debugPrint('Pickup address step data auto-saved');
    } catch (e) {
      // Silently catch errors related to ref after dispose
      debugPrint('Error while saving pickup address data: $e');
    }
  }

  void _loadExistingData() {
    final data = ref.read(profileFormDataProvider);
    
    // Check for each field and populate controllers
    if (data.containsKey('addressLine1') && data['addressLine1'] != null) {
      _addressDetailsController.text = data['addressLine1'] as String;
    }
    
    if (data.containsKey('nearbyLandmark') && data['nearbyLandmark'] != null) {
      _nearbyLandmarkController.text = data['nearbyLandmark'] as String;
    }
    
    if (data.containsKey('country') && data['country'] != null) {
      setState(() {
        _selectedCountry = data['country'] as String;
      });
    }

    if (data.containsKey('region') && data['region'] != null) {
      setState(() {
        _selectedRegion = data['region'] as String;
      });
    }
    
    // Also check for backward compatibility with older field names
    if (_addressDetailsController.text.isEmpty && data.containsKey('addressDetails')) {
      _addressDetailsController.text = data['addressDetails'] as String? ?? '';
    }
  }

  void _submitForm() {
    // First save form data regardless of validation
    _saveFormData();
    
    // Then validate for proceeding to next step
    final formKey = widget.formKey ?? _formKey;
    
    // Check country and region first, as these are most likely the issue
    if (_selectedCountry == null) {
      ToastService.show(
        context,
        "Please select a country",
        type: ToastType.error,
      );
      return;
    }

    if (_selectedRegion == null) {
      ToastService.show(
        context,
        "Please select a region",
        type: ToastType.error,
      );
      return;
    }
    
    // Then check the rest of the form validation
    if (formKey.currentState!.validate()) {
      // Navigate to next step using the callback
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Form(
      key: widget.formKey ?? _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section (simplified with less animation)
            Text(
              'Where can we pick up your orders?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the address where our courier can collect your packages',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Form fields - simplified without animations for better performance
            _buildFormFields(theme),
            
            const SizedBox(height: 40),
            
            // Navigation buttons
            _buildNavigationButtons(theme),
            
            const SizedBox(height: 16),
            
            // Help text for user to know data is saved
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Your progress is automatically saved when you switch tabs",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFormFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address Details
        AppTextField(
          label: 'Address Details',
          controller: _addressDetailsController,
          hintText: 'Street address, building, floor, etc.',
          validator: Validators.required,
        ),
        
        const SizedBox(height: 16),
        
        // Nearby Landmark
        AppTextField(
          label: 'Nearby Landmark (Optional)',
          controller: _nearbyLandmarkController,
          hintText: 'E.g., near mall, park, etc.',
        ),
        
        const SizedBox(height: 16),
        
        // Country dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Country',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: InputBorder.none,
                ),
                hint: const Text('Select country'),
                value: _selectedCountry,
                items: countries
                    .map((country) => DropdownMenuItem(value: country, child: Text(country)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                    _selectedRegion = null; // Reset region when country changes
                  });
                  // Auto-save when selection changes
                  _saveFormData();
                },
                validator: (value) => value == null ? 'Please select a country' : null,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),

        // Region dropdown
        if (_selectedCountry != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Region',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                  ),
                  hint: const Text('Select region'),
                  value: _selectedRegion,
                  items: regionsByCountry[_selectedCountry]!
                      .map((region) => DropdownMenuItem(value: region, child: Text(region)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value;
                    });
                    // Auto-save when selection changes
                    _saveFormData();
                  },
                  validator: (value) => value == null ? 'Please select a region' : null,
                ),
              ),
            ],
          ),
      ],
    );
  }
  
  Widget _buildNavigationButtons(ThemeData theme) {
    return Row(
      children: [
        // Back button
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: () {
              // Save data before going back
              _saveFormData();
              widget.onPrevious();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: theme.colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Back",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Next button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Next",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}