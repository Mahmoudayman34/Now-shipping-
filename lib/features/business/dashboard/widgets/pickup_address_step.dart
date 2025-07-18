import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import 'package:now_shipping/core/widgets/toast_.dart' show ToastService, ToastType;
import '../providers/profile_form_provider.dart';
import '../screens/map_location_picker.dart';
import '../models/location_model.dart';

class DashboardPickupAddressStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onPrevious;
  final GlobalKey<FormState>? formKey;
  final Function(Function)? onRegisterSave;
  final Color themeColor;
  
  const DashboardPickupAddressStep({
    super.key, 
    required this.onComplete,
    required this.onPrevious,
    this.formKey,
    this.onRegisterSave,
    this.themeColor = Colors.blue, // Default to blue if not provided
  });

  @override
  ConsumerState<DashboardPickupAddressStep> createState() => _DashboardPickupAddressStepState();
}

class _DashboardPickupAddressStepState extends ConsumerState<DashboardPickupAddressStep> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _addressDetailsController = TextEditingController();
  final TextEditingController _nearbyLandmarkController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedCountry;
  String? _selectedRegion;
  String? _selectedZone;
  
  // Location data from map
  double? _latitude;
  double? _longitude;
  String? _formattedAddress;
  
  final List<String> countries = [
    'Egypt',
  ];

  final Map<String, List<String>> regionsByCountry = {
    'Egypt': ['Cairo', 'Alexandria', 'Giza'],
  };
  
  // Zone data organized by region
  final Map<String, Map<String, List<String>>> zonesByRegion = {
    'Cairo': {
      'Downtown & Central': [
        'Downtown Cairo', 'Garden City', 'Zamalek', 'Dokki', 'Mohandessin', 
        'Agouza', 'Bulaq', 'Azbakeya', 'Abdeen', 'Attaba', 
        'Ramses', 'Qasr El Nil', 'Talaat Harb', 'Tahrir Square'
      ],
      'East': [
        'Nasr City', 'Nasr City - First Zone', 'Nasr City - Second Zone',
        'Nasr City - Third Zone', 'Nasr City - Fourth Zone', 'Nasr City - Seventh Zone',
        'Nasr City - Eighth Zone', 'Nasr City - Tenth Zone', 'Heliopolis',
        'Heliopolis - Korba', 'Heliopolis - Triumph', 'Heliopolis - Cleopatra',
        'Heliopolis - Almaza', 'Masr El Gedida', 'El Nozha', 'El Nozha El Gedida',
        'El Zeitoun', 'Ain Shams', 'Ain Shams - Ezbet El Nakhl', 'El Marg',
        'El Marg El Gedida', 'El Salam City', 'El Matariya', 'Hadayek El Qobba',
        'El Waili', 'Gesr El Suez', 'Cairo Airport', 'Sheraton', 'Sheraton Heliopolis'
      ],
      'South & New Cairo': [
        'Maadi', 'New Cairo', 'Fifth Settlement', 'First Settlement',
        'Katameya', 'El Mokattam', 'El Basateen', 'Dar El Salam',
        'El Rehab', 'El Tagamoa', 'El Shorouk', 'Badr City',
        'Helwan', '15th of May City', 'Hadayek Helwan'
      ],
      'West': [
        'Mohandessin', 'Dokki', 'Boulaq El Dakrour', 'Imbaba',
        'Agouza', 'Warraq', 'Rod El Farag', 'Shobra', 'Shobra El Kheima'
      ]
    },
    'Giza': {
      'Central & East': [
        'Giza Square', 'Dokki', 'Mohandessin', 'Agouza',
        'Haram', 'Faisal', 'Imbaba', 'Kit Kat', 'El Manial',
        'Boulaq El Dakrour', 'El Saff', 'El Hawamdeya'
      ],
      'West': [
        '6th of October', 'Sheikh Zayed', 'Smart Village', 'El Moatamadeya',
        'Dahshur', 'Kirdasah', 'Remaya Square', 'Hadayek El Ahram',
        'El Wahat Road', 'El Mansuriya', 'El Haram', 'Mariotiya', 'Abu Rawash'
      ]
    },
    'Alexandria': {
      'Downtown & East': [
        'Raml Station', 'Raml Station - Azarita', 'Raml Station - Mansheya',
        'Sidi Gaber', 'Sidi Gaber - Mostafa Kamel', 'Sidi Gaber Station',
        'Cleopatra', 'Cleopatra - Tram Station', 'Sporting', 'Sporting - El Bostan',
        'Stanley', 'Stanley - El Asafra', 'Stanley Bridge', 'San Stefano',
        'San Stefano Mall', 'Gleem', 'Gleem Bay', 'Rushdy', 'Saba Pasha',
        'Kafr Abdo', 'Camp Caesar', 'Smouha', 'Victoria', 'Bolkly',
        'Ibrahimia', 'Laurent', 'Loran'
      ],
      'Central & West': [
        'Bahary', 'Anfushi', 'Manshiya', 'Attarin', 'Gomrok',
        'Karmouz', 'Moharam Bek', 'Dekhela', 'Agami', 'Amreya',
        'Borg El Arab', 'King Mariout', 'Wardian', 'Bacos'
      ],
      'East & Montaza': [
        'Sidi Bishr', 'Miami', 'Asafra', 'Mandara', 'Montaza', 'Abu Qir',
        'El Maamoura', 'El Max', 'Aboukir', 'Semouha', 'Fleming',
        'El Zahria', 'Gianaclis'
      ]
    }
  };
  
  // Keep track of available zones based on selected region
  List<String> _availableZones = [];
  
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
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Method to save current form data without validation
  void _saveFormData() {
    // Save current state to provider even if incomplete
    final formData = {
      'addressLine1': _addressDetailsController.text,
      'addressDetails': _addressDetailsController.text, // Add for API compatibility
      'nearbyLandmark': _nearbyLandmarkController.text,
      'phoneNumber': _phoneNumberController.text,
      'pickupPhone': _phoneNumberController.text, // Add for API compatibility
      'country': _selectedCountry,
      'region': _selectedRegion,
      'city': _selectedRegion, // Make sure city is also set as it's required
      'zone': _selectedZone, // Save the selected zone
      'latitude': _latitude,
      'longitude': _longitude,
      'formattedAddress': _formattedAddress,
      'pickupLocationString': _formattedAddress, // Add for API compatibility
      'pickupCoordinates': _latitude != null && _longitude != null ? "$_latitude,$_longitude" : null,
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

    if (data.containsKey('phoneNumber') && data['phoneNumber'] != null) {
      _phoneNumberController.text = data['phoneNumber'] as String;
    }
    
    if (data.containsKey('country') && data['country'] != null) {
      setState(() {
        _selectedCountry = data['country'] as String;
      });
    }

    if (data.containsKey('region') && data['region'] != null) {
      setState(() {
        _selectedRegion = data['region'] as String;
        
        // Load available zones for this region
        if (_selectedRegion != null && zonesByRegion.containsKey(_selectedRegion)) {
          _availableZones = zonesByRegion[_selectedRegion]!.values.expand((zones) => zones).toList();
        }
      });
    }
    
    if (data.containsKey('zone') && data['zone'] != null) {
      setState(() {
        _selectedZone = data['zone'] as String;
      });
    }

    // Load map location data if it exists
    if (data.containsKey('latitude') && data['latitude'] != null) {
      _latitude = data['latitude'] as double;
    }

    if (data.containsKey('longitude') && data['longitude'] != null) {
      _longitude = data['longitude'] as double;
    }

    if (data.containsKey('formattedAddress') && data['formattedAddress'] != null) {
      _formattedAddress = data['formattedAddress'] as String;
    }
    
    // Also check for backward compatibility with older field names
    if (_addressDetailsController.text.isEmpty && data.containsKey('addressDetails')) {
      _addressDetailsController.text = data['addressDetails'] as String? ?? '';
    }
  }

  // Open map location picker
  Future<void> _openLocationPicker() async {
    final LocationData? result = await Navigator.push<LocationData>(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );

    // Process the selected location data
    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _formattedAddress = result.formattedAddress;
        
        // Update address field with formatted address if provided
        if (result.formattedAddress != null && result.formattedAddress!.isNotEmpty) {
          _addressDetailsController.text = result.formattedAddress!;
        }

        // Update country, region and zone if available
        if (result.country != null && result.country!.isNotEmpty) {
          _selectedCountry = result.country;
        }

        if (result.region != null && result.region!.isNotEmpty) {
          _selectedRegion = result.region;
          
          // Update available zones for the selected region
          if (_selectedRegion != null && zonesByRegion.containsKey(_selectedRegion)) {
            _availableZones = zonesByRegion[_selectedRegion]!.values.expand((zones) => zones).toList();
          }
        }

        if (result.zone != null && result.zone!.isNotEmpty) {
          // Try to match with an available zone
          if (_availableZones.any((zone) => zone.toLowerCase().contains(result.zone!.toLowerCase()))) {
            _selectedZone = _availableZones.firstWhere(
              (zone) => zone.toLowerCase().contains(result.zone!.toLowerCase()),
              orElse: () => _availableZones.first,
            );
          } else if (_availableZones.isNotEmpty) {
            _selectedZone = _availableZones.first;
          }
        }
      });
      
      // Save the updated data
      _saveFormData();
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
    
    // Check for zone selection if zones are available for this region
    if (_availableZones.isNotEmpty && _selectedZone == null) {
      ToastService.show(
        context,
        "Please select a zone",
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
                color: Color(0xffF29620),
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
            
            // Map location button (new)
            _buildMapLocationSelector(theme),
            
            const SizedBox(height: 24),
            
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
  
  // New method to build the map location selector
  Widget _buildMapLocationSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select location on map',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        
        // Map container with button
        InkWell(
          onTap: _openLocationPicker,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
            ),
            child: Stack(
              children: [
                // Instead of trying to load a static image that's failing with 403,
                // show a placeholder with map pattern
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: _latitude != null && _longitude != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 40,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Location Selected',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ), 
                              const SizedBox(height: 4),
                              Text(
                                'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
                
                // Overlay with prompt to tap
                if (_latitude == null || _longitude == null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Tap to select location on map',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Tap to change location on map',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Show selected coordinates if available
        if (_latitude != null && _longitude != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _formattedAddress ?? 'Location selected at: $_latitude, $_longitude',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
      ],
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

        // Phone Number
        AppTextField(
          label: 'Phone Number (Optional)',
          controller: _phoneNumberController,
          hintText: 'Enter your phone number',
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
                    _selectedZone = null; // Reset zone when country changes
                    _availableZones = []; // Clear available zones
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
                      _selectedZone = null; // Reset zone when region changes
                      _availableZones = zonesByRegion[_selectedRegion]?.values.expand((zones) => zones).toList() ?? [];
                    });
                    // Auto-save when selection changes
                    _saveFormData();
                  },
                  validator: (value) => value == null ? 'Please select a region' : null,
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 16),

        // Zone dropdown
        if (_selectedRegion != null && _availableZones.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zone',
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
                  hint: const Text('Select zone'),
                  value: _selectedZone,
                  items: _availableZones
                      .map((zone) => DropdownMenuItem(value: zone, child: Text(zone)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedZone = value;
                    });
                    // Auto-save when selection changes
                    _saveFormData();
                  },
                  validator: (value) => value == null ? 'Please select a zone' : null,
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
            onPressed: widget.onPrevious,
            style: OutlinedButton.styleFrom(
            foregroundColor: widget.themeColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: widget.themeColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            ),
            child: const Text(
              "Back",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
                      backgroundColor: widget.themeColor,
                      foregroundColor: Colors.white,
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}