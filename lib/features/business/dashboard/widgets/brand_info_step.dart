import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/features/business/dashboard/providers/profile_form_provider.dart';
import '../../../common/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import 'package:tes1/core/widgets/toast_.dart' show ToastService, ToastType;
import 'profile_completion_form.dart';

class DashboardBrandInfoStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onPrevious;
  final GlobalKey<FormState>? formKey;
  final Function(Function)? onRegisterSave;
  
  const DashboardBrandInfoStep({
    super.key, 
    required this.onComplete,
    required this.onPrevious,
    this.formKey,
    this.onRegisterSave,
  });

  @override
  ConsumerState<DashboardBrandInfoStep> createState() => _DashboardBrandInfoStepState();
}

class _DashboardBrandInfoStepState extends ConsumerState<DashboardBrandInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _brandNameController = TextEditingController();
  
  String? _selectedIndustry;
  String? _selectedVolume;
  final Set<String> _selectedChannels = {};

  final industryOptions = ['Fashion', 'Electronics', 'Beauty', 'Food', 'Other'];
  final volumeOptions = ['< 50 orders/month', '50-100', '100-500', '500+'];

  final sellingChannels = [
    'Instagram',
    'TikTok',
    'WooCommerce',
    'Custom Website',
    'Facebook Shop',
    'Facebook Messenger',
    'Shopify',
  ];

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

  // Method to save current form data without validation
  void _saveFormData() {
    // Save current state to provider even if incomplete
    final formData = {
      'brandName': _brandNameController.text,
      'industry': _selectedIndustry,
      'volume': _selectedVolume,
      'channels': _selectedChannels.toList(),
    };
    
    // Update the provider
    final currentData = ref.read(profileFormDataProvider);
    ref.read(profileFormDataProvider.notifier).state = {
      ...currentData,
      ...formData,
    };
    
    debugPrint('Brand info step data auto-saved');
  }

  void _loadExistingData() {
    final data = ref.read(profileFormDataProvider);
    if (data.containsKey('brandName') && data['brandName'] != null) {
      _brandNameController.text = data['brandName'] as String;
    }
    
    if (data.containsKey('industry') && data['industry'] != null) {
      setState(() {
        _selectedIndustry = data['industry'] as String;
      });
    }
    
    if (data.containsKey('volume') && data['volume'] != null) {
      setState(() {
        _selectedVolume = data['volume'] as String;
      });
    }
    
    if (data.containsKey('channels') && data['channels'] != null) {
      setState(() {
        _selectedChannels.clear();
        _selectedChannels.addAll((data['channels'] as List<dynamic>).cast<String>());
      });
    }
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: widget.formKey ?? _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated header section
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell us about your brand',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This helps us customize your experience',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Brand Name with animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(30 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: AppTextField(
                label: 'Brand Name',
                controller: _brandNameController,
                hintText: 'Enter your brand name',
                validator: Validators.required,
                // Auto-save on text change
                onChanged: (value) {
                  // We could call _saveFormData here for real-time saving,
                  // but to avoid excessive updates, we'll let the tab change trigger the save
                },
              ),
            ),
            
            const SizedBox(height: 24),

            // Industry Dropdown with animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 700),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(30 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Industry',
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
                      decoration: const InputDecoration(
                        hintText: 'Select your industry',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: InputBorder.none,
                      ),
                      value: _selectedIndustry,
                      items: industryOptions
                          .map((industry) => DropdownMenuItem(value: industry, child: Text(industry)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedIndustry = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select an industry' : null,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Monthly Order Volume Dropdown with animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(30 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Order Volume',
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
                      decoration: const InputDecoration(
                        hintText: 'Select your volume',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: InputBorder.none,
                      ),
                      value: _selectedVolume,
                      items: volumeOptions
                          .map((volume) => DropdownMenuItem(value: volume, child: Text(volume)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVolume = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select order volume' : null,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Selling Channels section with animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 900),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Where do you sell your products?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select all that apply',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: sellingChannels.map((channel) {
                      final isSelected = _selectedChannels.contains(channel);
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: FilterChip(
                          label: Text(channel),
                          selected: isSelected,
                          showCheckmark: false,
                          avatar: isSelected ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.onPrimary,
                            size: 18,
                          ) : null,
                          labelStyle: TextStyle(
                            color: isSelected 
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: theme.colorScheme.surface,
                          selectedColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected 
                                  ? theme.colorScheme.primary 
                                  : theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                          elevation: isSelected ? 2 : 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedChannels.add(channel);
                              } else {
                                _selectedChannels.remove(channel);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Navigation buttons row
            Row(
              children: [
                // Go back button - now properly using the onPrevious callback
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
                
                // Continue button
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
            ),
            
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

  void _submitForm() {
    // First save form data regardless of validation
    _saveFormData();
    
    // Then validate for proceeding to next step
    final formKey = widget.formKey ?? _formKey;
    if (formKey.currentState!.validate()) {
      if (_selectedChannels.isEmpty) {
        ToastService.show(
          context,
          "Please select at least one selling channel",
          type: ToastType.error,
        );
        return;
      }

      // Navigate to next step using the callback
      widget.onComplete();
      FocusScope.of(context).unfocus();
    }
  }
}