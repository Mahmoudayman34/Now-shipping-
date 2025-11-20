import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/core/widgets/toast_.dart';
import 'package:now_shipping/features/business/dashboard/providers/profile_form_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class DashboardBrandTypeStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onPrevious;
  final GlobalKey<FormState>? formKey;
  final Function(Function)? onRegisterSave;
  final VoidCallback? validateAndSubmit;
  final Color themeColor;
  
  const DashboardBrandTypeStep({
    super.key,
    required this.onComplete,
    required this.onPrevious,
    this.formKey,
    this.onRegisterSave,
    this.validateAndSubmit,
    this.themeColor = Colors.blue, // Default to blue if not provided
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
  double _uploadProgress = 0.0;

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
        final List<String> documentPhotos = List<String>.from(currentData['documentPhotos'] ?? []);
        ref.read(profileFormDataProvider.notifier).state = {
          ...currentData,
          ...formData,
          'documentPhotos': documentPhotos, // Ensure documentPhotos is saved
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

  // Method to pick image from gallery and upload to Cloudinary
  Future<void> _pickImage() async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });
      
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      
      if (pickedFiles.isNotEmpty) {
        // Convert XFile list to File list
        final List<File> files = pickedFiles.map((xFile) => File(xFile.path)).toList();
        
        // Upload multiple files and get list of URLs
        final List<String> uploadedUrls = await _uploadMultipleToCloudinary(files);
        
        // Print all URLs to console
        print('All Cloudinary Upload URLs: $uploadedUrls');
        
        // Toast notification
        ToastService.show(
          context,
          'Uploaded ${uploadedUrls.length} files successfully',
          type: ToastType.success,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      ToastService.show(
        context,
        'Error uploading documents: $e',
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Method to upload multiple files and return list of URLs
  Future<List<String>> _uploadMultipleToCloudinary(List<File> files) async {
    const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dusod9wxt/upload';
    const cloudinaryUploadPreset = 'order_project';
    final List<String> uploadedUrls = [];
    final int totalFiles = files.length;
    int filesUploaded = 0;
    
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });
      
      // Upload each file sequentially
      for (final file in files) {
        // Create a multipart request
        final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
          ..files.add(await http.MultipartFile.fromPath('file', file.path))
          ..fields['upload_preset'] = cloudinaryUploadPreset;

        // Send the request
        final response = await request.send();
        
        // Parse response
        final responseData = await response.stream.bytesToString();
        
        if (response.statusCode == 200) {
          // Parse the JSON response
          final parsedResponse = json.decode(responseData);
          final uploadedUrl = parsedResponse['secure_url'];
          
          // Add URL to our list
          uploadedUrls.add(uploadedUrl);
          
          // Add the file to our local list for display
          setState(() {
            _uploadedFiles.add(file);
            // Update progress
            filesUploaded++;
            _uploadProgress = filesUploaded / totalFiles;
          });

          // Save the uploaded file URL to provider
          final currentData = ref.read(profileFormDataProvider);
          final String key = _selectedBrandType == 'company' ? 'companyDocs' : 'idDocs';

          // Store the Cloudinary URLs in the provider for both type-specific field and documentPhotos
          final List<String> currentUrls = List<String>.from(currentData[key] ?? []);
          currentUrls.add(uploadedUrl);
          
          // Also add to documentPhotos which is required by validation
          final List<String> documentPhotos = List<String>.from(currentData['documentPhotos'] ?? []);
          documentPhotos.add(uploadedUrl);
          
          ref.read(profileFormDataProvider.notifier).state = {
            ...currentData,
            key: currentUrls,
            'documentPhotos': documentPhotos, // Add the required field name
          };
        } else {
          throw Exception('Failed to upload document: ${response.statusCode} ${response.reasonPhrase}');
        }
      }
      
      return uploadedUrls;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ToastService.show(
        context,
        'Error uploading documents: $e',
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
      return uploadedUrls; // Return any URLs that were successful before error
    }
  }
  
  // Method to remove a file from the uploads
  void _removeFile(int index) {
    if (index < 0 || index >= _uploadedFiles.length) return;
    
    // Record the file path before removing it
    final String filePathToRemove = _uploadedFiles[index].path;
    
    setState(() {
      _uploadedFiles.removeAt(index);
    });
    
    // Update the provider
    final currentData = ref.read(profileFormDataProvider);
    final String key = _selectedBrandType == 'company' ? 'companyDocs' : 'idDocs';
    
    // Update type-specific document paths
    List<String> typeDocs = List<String>.from(currentData[key] ?? []);
    if (typeDocs.length > index) {
      typeDocs.removeAt(index);
    }
    
    // Also update documentPhotos field that validation requires
    List<String> documentPhotos = List<String>.from(currentData['documentPhotos'] ?? []);
    // Find the matching file in documentPhotos and remove it
    int docPhotoIndex = documentPhotos.indexWhere((path) => path == filePathToRemove || path.contains(filePathToRemove));
    if (docPhotoIndex != -1) {
      documentPhotos.removeAt(docPhotoIndex);
    } else if (documentPhotos.length > index) {
      // As a fallback, remove by index if we can't find by path
      documentPhotos.removeAt(index);
    }
    
    ref.read(profileFormDataProvider.notifier).state = {
      ...currentData,
      key: typeDocs,
      'documentPhotos': documentPhotos, // Update the document photos field
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
                      color: Color(0xffF29620),
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
                          borderSide: const BorderSide(color: Color(0xffF29620)),
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
                                label: const Text('Upload Multiple Documents'),
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
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: _uploadProgress,
                                          color: Colors.orange,
                                        ),
                                        Text(
                                          '${(_uploadProgress * 100).toInt()}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Uploading ${(_uploadProgress * 100).toInt()}% complete'),
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
                      foregroundColor: widget.themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: widget.themeColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back',
                    style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),),
                  ),
                ),

                const SizedBox(width: 16),

                // Submit button (renamed from Next)
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: (_isSubmitting || _isUploading) ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: widget.themeColor.withOpacity(0.3),
                      disabledForegroundColor: Colors.white.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("Submitting..."),
                            ],
                          )
                        : _isUploading
                            ? const Text(
                                "Please wait for upload to complete",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              )
                            : const Text(
                                "Submit Profile",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
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