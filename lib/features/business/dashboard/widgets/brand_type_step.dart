import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/core/widgets/toast_.dart';
import 'package:tes1/features/business/dashboard/providers/profile_form_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DashboardBrandTypeStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onPrevious;
  final VoidCallback? validateAndSubmit; // For validation
  final GlobalKey<FormState>? formKey;
  final Function(Function)? onRegisterSave;

  const DashboardBrandTypeStep({
    super.key,
    required this.onComplete,
    required this.onPrevious,
    this.validateAndSubmit,
    this.formKey,
    this.onRegisterSave,
  });

  @override
  ConsumerState<DashboardBrandTypeStep> createState() => _DashboardBrandTypeStepState();
}

class _DashboardBrandTypeStepState extends ConsumerState<DashboardBrandTypeStep> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBrandType;
  bool _isSubmitting = false;
  
  // Variables for document uploads
  final ImagePicker _picker = ImagePicker();
  final List<File> _uploadedFiles = [];
  bool _isUploading = false;

  final brandTypes = [
    {
      'id': 'individual',
      'title': 'Individual',
      'icon': Icons.person_outline,
    },
    {
      'id': 'company',
      'title': 'Company',
      'icon': Icons.business_outlined,
    },
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
    // Check if widget is still mounted before using ref
    if (!mounted) return;
    
    if (_selectedBrandType != null) {
      // Save data to provider
      final formData = {
        'brandType': _selectedBrandType,
      };

      try {
        // Update the provider
        final currentData = ref.read(profileFormDataProvider);
        ref.read(profileFormDataProvider.notifier).state = {
          ...currentData,
          ...formData,
        };
        
        debugPrint('Brand type step data auto-saved');
      } catch (e) {
        // Silently catch errors related to ref after dispose
        debugPrint('Error while saving brand type data: $e');
      }
    }
  }

  void _loadExistingData() {
    final data = ref.read(profileFormDataProvider);
    if (data.containsKey('brandType') && data['brandType'] != null) {
      setState(() {
        _selectedBrandType = data['brandType'] as String;
      });
    }
  }

  // Method to pick image from gallery
  Future<void> _pickImage() async {
    try {
      setState(() {
        _isUploading = true;
      });
      
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          _uploadedFiles.add(file);
        });
        
        // Save the uploaded file paths to provider
        final currentData = ref.read(profileFormDataProvider);
        final String key = _selectedBrandType == 'company' ? 'companyDocs' : 'idDocs';
        
        // Store uploaded file paths
        List<String> filePaths = [];
        for (var file in _uploadedFiles) {
          filePaths.add(file.path);
        }
        
        ref.read(profileFormDataProvider.notifier).state = {
          ...currentData,
          key: filePaths,
        };
        
        ToastService.show(
          context,
          'Document uploaded successfully',
          type: ToastType.success,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      ToastService.show(
        context,
        'Error uploading document: $e',
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  
  // Method to remove a file from the uploads
  void _removeFile(int index) {
    if (index < 0 || index >= _uploadedFiles.length) return;
    
    setState(() {
      _uploadedFiles.removeAt(index);
    });
    
    // Update the provider
    final currentData = ref.read(profileFormDataProvider);
    final String key = _selectedBrandType == 'company' ? 'companyDocs' : 'idDocs';
    
    // Update file paths
    List<String> filePaths = [];
    for (var file in _uploadedFiles) {
      filePaths.add(file.path);
    }
    
    ref.read(profileFormDataProvider.notifier).state = {
      ...currentData,
      key: filePaths,
    };
    
    ToastService.show(
      context,
      'Document removed',
      type: ToastType.info,
      duration: const Duration(seconds: 2),
    );
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
            // Header
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
                    'What type of seller are you?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This helps us tailor our services to your needs',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Brand type options with animation
            ...List.generate(brandTypes.length, (index) {
              final type = brandTypes[index];
              final isSelected = _selectedBrandType == type['id'];

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 100)),
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildBrandTypeOption(
                    id: type['id'] as String,
                    title: type['title'] as String,
                    description: '', // No description provided in the new structure
                    icon: type['icon'] as IconData,
                    isSelected: isSelected,
                    theme: theme,
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),
            
            // Dynamic fields based on brand type selection
            if (_selectedBrandType != null)
              AnimatedOpacity(
                opacity: _selectedBrandType != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tax ID / National ID field
                    Text(
                      _selectedBrandType == 'company' 
                          ? 'Enter your Tax Number:' 
                          : 'Enter your National ID Number:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: _selectedBrandType == 'company' 
                            ? 'Example: 1234567890' 
                            : 'Example: 29811234',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _selectedBrandType == 'company'
                              ? 'Please enter your tax number'
                              : 'Please enter your national ID number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          final currentData = ref.read(profileFormDataProvider);
                          ref.read(profileFormDataProvider.notifier).state = {
                            ...currentData,
                            _selectedBrandType == 'company' ? 'taxNumber' : 'nationalIdNumber': value,
                          };
                        }
                      },
                      onChanged: (value) {
                        // Save data on change
                        final currentData = ref.read(profileFormDataProvider);
                        ref.read(profileFormDataProvider.notifier).state = {
                          ...currentData,
                          _selectedBrandType == 'company' ? 'taxNumber' : 'nationalIdNumber': value,
                        };
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Document upload section
                    Text(
                      _selectedBrandType == 'company' 
                          ? 'Upload Company Papers:' 
                          : 'Upload National ID:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _selectedBrandType == 'company'
                                  ? 'Upload Papers'
                                  : 'Upload Your National ID',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedBrandType == 'company'
                                ? 'Please Upload All Papers'
                                : 'Upload Front Side And Back Side',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Show upload options
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isUploading ? null : _pickImage,
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Upload Document'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                          
                          // Loading indicator while uploading
                          if (_isUploading)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.orange,
                                    ),
                                    SizedBox(height: 8),
                                    Text('Uploading document...'),
                                  ],
                                ),
                              ),
                            ),
                            
                          // Display uploaded files
                          if (_uploadedFiles.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Uploaded Documents',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxHeight: 200,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _uploadedFiles.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          elevation: 2,
                                          margin: const EdgeInsets.only(bottom: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ListTile(
                                            leading: ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: Image.file(
                                                _uploadedFiles[index],
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            title: Text(
                                              'Document ${index + 1}',
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            subtitle: Text(
                                              _uploadedFiles[index].path.split('/').last,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _removeFile(index),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // Navigation buttons
            Row(
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
                    child: const Text('Back'),
                  ),
                ),

                const SizedBox(width: 16),

                // Submit button (renamed from Next)
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.3),
                      disabledForegroundColor: theme.colorScheme.onPrimary.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text("Submitting..."),
                            ],
                          )
                        : const Text(
                            "Submit Profile",
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

            // Help text explaining auto-save and validation
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      "Your progress is automatically saved when you switch tabs",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "This is the final step, we'll check if all required information is complete",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandTypeOption({
    required String id,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required ThemeData theme,
  }) {
    // Define orange color for the cards
    const orangeColor = Colors.orange;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBrandType = id;
        });
        // Auto-save when user makes a selection
        _saveFormData();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? orangeColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? orangeColor.withOpacity(0.05) : Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          children: [
            Icon(
              icon,
              color: Colors.orange.shade700,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 18,
                color: isSelected ? orangeColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_selectedBrandType == null) {
      // Show error message if no brand type is selected
      ToastService.show(
        context, 
        'Please select your seller type',
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Save form data before validation
    _saveFormData();

    setState(() {
      _isSubmitting = true;
    });

    // Use the validateAndSubmit callback to check all required fields
    if (widget.validateAndSubmit != null) {
      // Short delay to allow state update and show loading indicator
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          widget.validateAndSubmit!();
          // Reset submitting state in case we stay on this screen
          // (if there are validation errors)
          setState(() {
            _isSubmitting = false;
          });
        }
      });
    } else {
      // Fallback to normal onComplete if validateAndSubmit is not provided
      widget.onComplete();
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}