import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:convert';
import 'package:now_shipping/features/business/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:now_shipping/core/l10n/app_localizations.dart';
import 'package:now_shipping/core/utils/responsive_utils.dart';

class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    
    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).personalInformation,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 18, 
                tablet: 20, 
                desktop: 22,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new, 
              color: const Color(0xFF2F2F2F),
              size: ResponsiveUtils.getResponsiveIconSize(context),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: userData.when(
          data: (user) {
            if (user == null) {
              return Center(
                child: Text(
                  AppLocalizations.of(context).noUserDataAvailable,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context, 
                      mobile: 14, 
                      tablet: 16, 
                      desktop: 18,
                    ),
                  ),
                ),
              );
            }
            
            return SingleChildScrollView(
              padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      _buildProfileAvatar(user),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).profilePicture,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xfff29620),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  AppLocalizations.of(context).basicInformation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff29620),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildInfoItem(AppLocalizations.of(context).fullName, user.name),
                _buildInfoItem(AppLocalizations.of(context).email, user.email),
                _buildInfoItem(AppLocalizations.of(context).phone, user.phoneNumber),
                
                const SizedBox(height: 24),
                
                Text(
                  AppLocalizations.of(context).businessInformation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff29620),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildInfoItem(AppLocalizations.of(context).businessName, user.brandInfo.brandName),
                _buildInfoItem(AppLocalizations.of(context).role, _formatRole(user.role)),
                _buildInfoItem(AppLocalizations.of(context).storageNeeded, user.isNeedStorage ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no),
                _buildInfoItem(AppLocalizations.of(context).accountStatus, _getAccountStatus(user, context)),
                _buildInfoItem(AppLocalizations.of(context).registeredDate, _formatDate(user.createdAt)),
/*                
                const SizedBox(height: 24),
                
                const Text(
                  'Pickup Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff29620),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildInfoItem('Country', user.pickUpAddress.country),
                _buildInfoItem('City', user.pickUpAddress.city),
                _buildInfoItem('Address Details', user.pickUpAddress.addressDetails),
                _buildInfoItem('Nearby Landmark', user.pickUpAddress.nearbyLandmark),
                _buildInfoItem('Pickup Phone', user.pickUpAddress.pickupPhone),
               */ 
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to edit profile
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditPersonalInfoScreen(),
                        ),
                      ).then((_) {
                        // Refresh user data when returning from edit screen
                        ref.invalidate(userDataProvider);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff29620),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context).editInformation),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xfff29620),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading profile: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userDataProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff29620),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
  
  Widget _buildProfileAvatar(UserModel user) {
    final hasValidImage = user.profileImage.isNotEmpty && 
                          user.profileImage != "https://example.com/images/profile.jpg";
    
    if (!hasValidImage) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.grey[400],
        ),
      );
    }
    
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[200],
      backgroundImage: NetworkImage(user.profileImage),
      onBackgroundImageError: (exception, stackTrace) {
        // This handles network image loading errors silently
        print('Error loading profile image: $exception');
      },
      // Add a fallback child that will be displayed if the image fails to load
      child: null,
    );
  }
  
  String _formatRole(String role) {
    if (role.isEmpty) return 'N/A';
    return role.substring(0, 1).toUpperCase() + role.substring(1);
  }
  
  String _getAccountStatus(UserModel user, BuildContext context) {
    if (user.isVerified && user.isCompleted) {
      return AppLocalizations.of(context).active;
    } else if (user.isCompleted) {
      return AppLocalizations.of(context).pendingVerification;
    } else {
      return AppLocalizations.of(context).inactive;
    }
  }
  
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditPersonalInfoScreen extends ConsumerStatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  ConsumerState<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends ConsumerState<EditPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _pickupPhoneController;
  
  bool _isLoading = false;
  File? _imageFile;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _initialDataLoaded = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty strings first
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _businessNameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();
    _landmarkController = TextEditingController();
    _pickupPhoneController = TextEditingController();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialDataLoaded) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    final userData = ref.read(userDataProvider);
    
    userData.when(
      data: (user) {
        if (user != null) {
          setState(() {
            _nameController.text = user.name;
            _phoneController.text = user.phoneNumber;
            _businessNameController.text = user.brandInfo.brandName;
            _addressController.text = user.pickUpAddress.addressDetails;
            _cityController.text = user.pickUpAddress.city;
            _countryController.text = user.pickUpAddress.country;
            _landmarkController.text = user.pickUpAddress.nearbyLandmark;
            _pickupPhoneController.text = user.pickUpAddress.pickupPhone;
            
            _profileImageUrl = user.profileImage.isNotEmpty && 
                               user.profileImage != "https://example.com/images/profile.jpg" 
                               ? user.profileImage : null;
            _initialDataLoaded = true;
          });
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _landmarkController.dispose();
    _pickupPhoneController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isLoading = true;
      });
      
      // Upload to Cloudinary
      try {
        String? uploadedUrl = await _uploadToCloudinary(_imageFile!);
        setState(() {
          _profileImageUrl = uploadedUrl;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
        }
      }
    }
  }

  Future<String?> _uploadToCloudinary(File imageFile) async {
    const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dusod9wxt/upload';
    const cloudinaryUploadPreset = 'order_project';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
        ..files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        )
        ..fields['upload_preset'] = cloudinaryUploadPreset;

      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final String responseString = String.fromCharCodes(responseData);
        
        // Parse the JSON response
        final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(
          jsonDecode(responseString) as Map,
        );
        final uploadedUrl = jsonMap['secure_url'] as String?;
        return uploadedUrl;
      } else {
        final responseData = await response.stream.toBytes();
        final String responseString = String.fromCharCodes(responseData);
        print('Cloudinary Error Response: $responseString');
      }
      return null;
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Get the user service to update profile
      final userService = ref.read(userServiceProvider);
      
      try {
        final success = await userService.updateUserProfile(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          brandName: _businessNameController.text,
          profileImage: _profileImageUrl,
        );
        
        if (success) {
          // Refresh user data provider to update UI
          ref.invalidate(userDataProvider);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          // Handle error
          setState(() {
            _errorMessage = 'Failed to update profile. Please try again.';
          });
        }
      } catch (e) {
        // Handle exception
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataProvider);
    
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).editPersonalInformation,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 18, 
                tablet: 20, 
                desktop: 22,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new, 
              color: const Color(0xFF2F2F2F),
              size: ResponsiveUtils.getResponsiveIconSize(context),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: userData.when(
          data: (_) => SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.isTablet(context) 
                      ? MediaQuery.of(context).size.width * 0.8
                      : double.infinity,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Display error message if there is one
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          _buildProfileAvatar(),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xfff29620),
                                border: Border.all(width: 2, color: Colors.white),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                onPressed: _getImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).tapToChangeProfilePicture,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  AppLocalizations.of(context).basicInformation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff29620),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).fullName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterYourName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).phone,
                    border: const OutlineInputBorder(),
                    counterText: '', // Hide the character counter
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterYourPhoneNumber;
                    }
                    return null;
                  },
                ),
        
                const SizedBox(height: 24),
                
                Text(
                  AppLocalizations.of(context).businessInformation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff29620),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _businessNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).businessName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterYourBusinessName;
                    }
                    return null;
                  },
                ),
                
                /* Commenting out Pickup Address section
                const SizedBox(height: 24),
                
                const Text(
                  'Pickup Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff29620),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter country';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address Details',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _landmarkController,
                  decoration: const InputDecoration(
                    labelText: 'Nearby Landmark',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _pickupPhoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  decoration: const InputDecoration(
                    labelText: 'Pickup Phone',
                    border: OutlineInputBorder(),
                    counterText: '', // Hide the character counter
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pickup phone';
                    }
                    return null;
                  },
                ),
                */
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff29620),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(AppLocalizations.of(context).saveChanges),
                  ),
                ),
              ],
          ),
        ),
        ),
        ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xfff29620),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading profile: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userDataProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff29620),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New method to build profile avatar with error handling
  Widget _buildProfileAvatar() {
    // Handle local image file first
    if (_imageFile != null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        backgroundImage: FileImage(_imageFile!),
      );
    }
    
    // Check if we have a valid profile image URL
    final hasValidImage = _profileImageUrl != null && 
                         _profileImageUrl!.isNotEmpty && 
                         _profileImageUrl != "https://example.com/images/profile.jpg";
    
    if (!hasValidImage) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[200],
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.grey[400],
        ),
      );
    }
    
    // Use network image with error handling
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[200],
      backgroundImage: NetworkImage(_profileImageUrl!),
      onBackgroundImageError: (exception, stackTrace) {
        // Handle error silently
        print('Error loading profile image: $exception');
        
        // If image fails to load during widget lifecycle, we can update state
        if (mounted) {
          setState(() {
            _profileImageUrl = null; // Reset the URL so default icon shows
          });
        }
      },
      child: null,
    );
  }
} 