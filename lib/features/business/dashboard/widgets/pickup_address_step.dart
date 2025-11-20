import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import 'package:now_shipping/core/widgets/toast_.dart' show ToastService, ToastType;
import '../providers/profile_form_provider.dart';
import '../screens/map_location_picker.dart';
import '../models/location_model.dart';
import '../models/pickup_address_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/regions_service.dart';
import '../../../../core/providers/locale_provider.dart';

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
  
  // List of addresses
  List<PickupAddress> _addresses = [];
  
  // Form keys for each address form
  final Map<String, GlobalKey<FormState>> _addressFormKeys = {};
  
  // Track which addresses are expanded
  final Set<String> _expandedAddresses = {};
  
  final List<String> countries = [
    'Egypt',
  ];

  final Map<String, List<String>> regionsByCountry = {
    'Egypt': ['Cairo'],
  };
  
  // Zones are now loaded dynamically from JSON files via RegionsService
  
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
    try {
      // Convert addresses to JSON format and mark first as default
      final addressesJson = _addresses.asMap().entries.map((entry) {
        final index = entry.key;
        final addr = entry.value;
        final addrJson = addr.toJson();
        // Mark first address as default
        if (index == 0) {
          addrJson['isDefault'] = true;
        }
        return addrJson;
      }).toList();
      
      // Save the first address data for backward compatibility
      final firstAddress = _addresses.isNotEmpty ? _addresses.first : null;
      
    final formData = {
        'pickupAddresses': addressesJson, // New format: list of addresses
        // Backward compatibility: save first address as main address
        if (firstAddress != null) ...{
          'addressLine1': firstAddress.addressDetails,
          'addressDetails': firstAddress.addressDetails,
          'nearbyLandmark': firstAddress.nearbyLandmark,
          'phoneNumber': firstAddress.phoneNumber,
          'pickupPhone': firstAddress.phoneNumber,
          'otherPhoneNumber': firstAddress.otherPhoneNumber,
          'country': firstAddress.country,
          'region': firstAddress.region,
          'city': firstAddress.region,
          'zone': firstAddress.zone,
          'latitude': firstAddress.latitude,
          'longitude': firstAddress.longitude,
          'formattedAddress': firstAddress.formattedAddress,
          'pickupLocationString': firstAddress.formattedAddress,
          'pickupCoordinates': firstAddress.latitude != null && firstAddress.longitude != null 
              ? "${firstAddress.latitude},${firstAddress.longitude}" 
              : null,
        },
    };
    
      // Update the provider
      final currentData = ref.read(profileFormDataProvider);
      ref.read(profileFormDataProvider.notifier).state = {
        ...currentData,
        ...formData,
      };
      
      debugPrint('Pickup address step data auto-saved (${_addresses.length} addresses)');
    } catch (e) {
      // Silently catch errors related to ref after dispose
      debugPrint('Error while saving pickup address data: $e');
    }
  }

  void _loadExistingData() {
    final data = ref.read(profileFormDataProvider);
    
    // Try to load new format first (list of addresses)
    if (data.containsKey('pickupAddresses') && data['pickupAddresses'] != null) {
      final List<dynamic> addressesList = data['pickupAddresses'] as List<dynamic>;
      setState(() {
        _addresses = addressesList
            .map((json) {
              final address = PickupAddress.fromJson(json as Map<String, dynamic>);
              // Set default values if not present
              return address.copyWith(
                country: address.country ?? 'Egypt',
                region: address.region ?? 'Cairo',
              );
            })
            .toList();
        
        // Initialize form keys for each address
        for (var address in _addresses) {
          if (address.id != null) {
            _addressFormKeys[address.id!] = GlobalKey<FormState>();
          }
        }
      });
    } else {
      // Backward compatibility: load single address from old format
      final address = PickupAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        addressName: 'Main Address',
        addressDetails: data['addressLine1'] ?? data['addressDetails'],
        nearbyLandmark: data['nearbyLandmark'],
        phoneNumber: data['phoneNumber'] ?? data['pickupPhone'],
        otherPhoneNumber: data['otherPhoneNumber'],
        country: data['country'] ?? 'Egypt', // Default to Egypt
        region: data['region'] ?? data['city'] ?? 'Cairo', // Default to Cairo
        zone: data['zone'],
        latitude: data['latitude']?.toDouble(),
        longitude: data['longitude']?.toDouble(),
        formattedAddress: data['formattedAddress'] ?? data['pickupLocationString'],
      );
      
      setState(() {
        _addresses = [address];
        if (address.id != null) {
          _addressFormKeys[address.id!] = GlobalKey<FormState>();
        }
      });
    }
    
    // If no addresses exist, create a default one
    if (_addresses.isEmpty) {
      _addNewAddress();
    } else {
      // Set defaults for any addresses missing country/region
      setState(() {
        _addresses = _addresses.map((address) {
          return address.copyWith(
            country: address.country ?? 'Egypt',
            region: address.region ?? 'Cairo',
          );
        }).toList();
      });
    
      // Expand the first address by default
      if (_addresses.isNotEmpty && _addresses.first.id != null) {
        _expandedAddresses.add(_addresses.first.id!);
    }
  }
  }

  void _addNewAddress() {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final addressNumber = _addresses.length + 1;
    final newAddress = PickupAddress(
      id: newId,
      addressName: addressNumber == 1 ? 'Main Address' : 'Address $addressNumber',
      country: 'Egypt', // Auto-select Egypt
      region: 'Cairo', // Auto-select Cairo as it's the only option
    );
    
      setState(() {
      _addresses.add(newAddress);
      _addressFormKeys[newId] = GlobalKey<FormState>();
      // Expand newly added address by default
      _expandedAddresses.add(newId);
    });
    
    _saveFormData();
  }

  void _removeAddress(String addressId) {
      setState(() {
      _addresses.removeWhere((addr) => addr.id == addressId);
      _addressFormKeys.remove(addressId);
      _expandedAddresses.remove(addressId);
    });

    // Ensure at least one address exists
    if (_addresses.isEmpty) {
      _addNewAddress();
    }
    
    _saveFormData();
        }

  void _toggleAddressExpansion(String addressId) {
    setState(() {
      if (_expandedAddresses.contains(addressId)) {
        _expandedAddresses.remove(addressId);
      } else {
        _expandedAddresses.add(addressId);
          }
    });
  }

  void _updateAddress(String addressId, PickupAddress updatedAddress) {
    setState(() {
      final index = _addresses.indexWhere((addr) => addr.id == addressId);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        }
      });
      _saveFormData();
  }

  void _submitForm() {
    // Validate all address forms
    bool allValid = true;
    for (var address in _addresses) {
      if (address.id != null && _addressFormKeys.containsKey(address.id!)) {
        final formKey = _addressFormKeys[address.id!];
        if (formKey?.currentState?.validate() != true) {
          allValid = false;
        }
      }
    }
    
    if (!allValid) {
      ToastService.show(
        context,
        "Please fill all required fields",
        type: ToastType.error,
      );
      return;
    }

    // Validate that at least one address has required fields
    bool hasValidAddress = false;
    for (var address in _addresses) {
      if (address.country != null && 
          address.region != null && 
          address.addressDetails != null && 
          address.addressDetails!.isNotEmpty) {
        hasValidAddress = true;
        break;
      }
    }
    
    if (!hasValidAddress) {
      ToastService.show(
        context,
        "Please add at least one complete address",
        type: ToastType.error,
      );
      return;
    }
    
    // Save before proceeding
    _saveFormData();
    
    // Navigate to next step
      widget.onComplete();
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
            // Header section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
            Text(
                            'Pickup Locations',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xffF29620),
              ),
            ),
                          const SizedBox(height: 4),
            Text(
                            'Add addresses where our courier can collect your packages',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add Address button - Icon only
                    Material(
                      color: Color(0xffF29620),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: _addNewAddress,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // List of addresses
            if (_addresses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No addresses added yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first address',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._addresses.asMap().entries.map((entry) {
                final index = entry.key;
                final address = entry.value;
                return _buildAddressCard(theme, address, index);
              }),
            
            const SizedBox(height: 40),
            
            // Navigation buttons
            _buildNavigationButtons(theme),
            
            const SizedBox(height: 16),
            
            // Help text
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
  
  Widget _buildAddressCard(ThemeData theme, PickupAddress address, int index) {
    final addressId = address.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final formKey = _addressFormKeys[addressId] ??= GlobalKey<FormState>();
    final addressNameController = TextEditingController(text: address.addressName);
    final isExpanded = _expandedAddresses.contains(addressId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
        color: Colors.white,
              borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? const Color(0xffF29620) : Colors.grey.shade300,
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
            ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Address header with name, expand/collapse, and delete button
            InkWell(
              onTap: () => _toggleAddressExpansion(addressId),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                Container(
                      padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                        color: const Color(0xffF29620).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                  ),
                      child: const Icon(
                                Icons.location_on,
                        color: Color(0xffF29620),
                        size: 20,
                      ),
                              ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Expand when tapping on the text field area
                          if (!isExpanded) {
                            _toggleAddressExpansion(addressId);
                          }
                        },
                        child: TextFormField(
                          controller: addressNameController,
                          decoration: InputDecoration(
                            hintText: 'Address Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xffF29620), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          onChanged: (value) {
                            _updateAddress(addressId, address.copyWith(addressName: value));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Expand/Collapse button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _toggleAddressExpansion(addressId),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: const Color(0xffF29620),
                            size: 24,
                            ),
                          ),
                        ),
                    ),
                    if (_addresses.length > 1) ...[
                      const SizedBox(width: 4),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _removeAddress(addressId),
                          borderRadius: BorderRadius.circular(8),
                      child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade400,
                              size: 22,
                        ),
                      ),
                    ),
                  ),
                    ],
              ],
            ),
          ),
        ),
        
            // Collapsible content
            if (isExpanded) ...[
              const Divider(height: 1, thickness: 1),
          Padding(
                padding: const EdgeInsets.all(20),
                child: _buildAddressFormFields(theme, address, addressId),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddressFormFields(ThemeData theme, PickupAddress address, String addressId) {
    // Controllers for this address - use key to ensure they update when address changes
    final addressDetailsController = TextEditingController(text: address.addressDetails ?? '');
    final nearbyLandmarkController = TextEditingController(text: address.nearbyLandmark ?? '');
    final phoneNumberController = TextEditingController(text: address.phoneNumber ?? '');
    final otherPhoneController = TextEditingController(text: address.otherPhoneNumber ?? '');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                key: ValueKey('country_${address.id}_${address.country}'),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: InputBorder.none,
                ),
                hint: const Text('Select country'),
                value: address.country != null && countries.contains(address.country) 
                    ? address.country 
                    : 'Egypt', // Default to Egypt
                items: countries
                    .map((country) => DropdownMenuItem(value: country, child: Text(country)))
                    .toList(),
                onChanged: (value) {
                    _updateAddress(addressId, address.copyWith(
                      country: value ?? 'Egypt', // Default to Egypt if null
                      region: 'Cairo', // Auto-select Cairo as it's the only option
                      zone: null, // Reset zone when country changes
                    ));
                },
                validator: (value) => value == null ? 'Please select a country' : null,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),

        // Governorate and Area dropdown
        if (address.country != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Governorate and Area *',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Click to select governorate and area',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  key: ValueKey('region_${address.id}_${address.region}'),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                  ),
                  hint: const Text('Select Area'),
                  value: address.region != null && regionsByCountry[address.country] != null 
                      && regionsByCountry[address.country]!.contains(address.region)
                      ? address.region 
                      : 'Cairo', // Default to Cairo
                  items: regionsByCountry[address.country]!
                      .map((region) => DropdownMenuItem(value: region, child: Text(region)))
                      .toList(),
                  onChanged: (value) {
                    _updateAddress(addressId, address.copyWith(
                      region: value ?? 'Cairo', // Default to Cairo if null
                      zone: null, // Reset zone when region changes
                    ));
                  },
                  validator: (value) => value == null ? 'Please select governorate and area' : null,
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 16),

        // Zone dropdown - loaded dynamically from JSON based on locale
        if (address.region != null)
          ref.watch(zonesForGovernorateProvider(address.region!)).when(
            data: (availableZones) {
              if (availableZones.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
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
                      key: ValueKey('zone_${address.id}_${address.zone}'),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                  ),
                  hint: const Text('Select zone'),
                      value: address.zone != null && availableZones.contains(address.zone)
                          ? address.zone 
                          : null, // Only set value if it's in the list
                      items: availableZones
                      .map((zone) => DropdownMenuItem(value: zone, child: Text(zone)))
                      .toList(),
                  onChanged: (value) {
                        _updateAddress(addressId, address.copyWith(zone: value));
                  },
                ),
              ),
            ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        
        const SizedBox(height: 16),
        
        // Address Details
        AppTextField(
          key: ValueKey('addressDetails_${address.id}_${address.addressDetails}'),
          label: 'Address Details *',
          controller: addressDetailsController,
          hintText: 'Street, Building, Floor, Apartment',
          validator: Validators.required,
          onChanged: (value) {
            _updateAddress(addressId, address.copyWith(addressDetails: value));
          },
        ),
        
        const SizedBox(height: 16),
        
        // Nearby Landmark
        AppTextField(
          label: 'Nearby Landmark (Optional)',
          controller: nearbyLandmarkController,
          hintText: 'e.g. Near the school',
          onChanged: (value) {
            _updateAddress(addressId, address.copyWith(nearbyLandmark: value));
          },
        ),
        
        const SizedBox(height: 16),
        
        // Pickup Phone Number
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pickup Phone Number *',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                hintText: 'e.g. 0 123 456 7890',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.required,
              onChanged: (value) {
                _updateAddress(addressId, address.copyWith(phoneNumber: value));
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Other Pickup Phone
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Other Pickup Phone (Optional)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: otherPhoneController,
              decoration: InputDecoration(
                hintText: 'e.g. 0 123 456 7890',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                _updateAddress(addressId, address.copyWith(otherPhoneNumber: value));
              },
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Location on Map section
        _buildMapLocationSelector(theme, address, addressId),
      ],
    );
  }
  
  Widget _buildMapLocationSelector(ThemeData theme, PickupAddress address, String addressId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location on Map (Optional)',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        
        // Get Location button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _getCurrentLocation(address, addressId),
            icon: const Icon(Icons.my_location, size: 18),
            label: const Text('Get Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff29620),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Map container - clickable to open map picker
        InkWell(
          onTap: () => _openLocationPicker(address, addressId),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: address.latitude != null && address.longitude != null
                    ? const Color(0xfff29620)
                    : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                // Background pattern
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                ),
                
                // Content based on state
                if (address.latitude == null || address.longitude == null)
                  // Empty state - no location selected
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xfff29620).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: Color(0xfff29620),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to select location on map',
                          style: TextStyle(
                            color: const Color(0xfff29620),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Location selected state
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xfff29620),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Location Selected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xfff29620),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xfff29620).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Tap to change location',
                            style: TextStyle(
                              color: const Color(0xfff29620),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Get current GPS location
  Future<void> _getCurrentLocation(PickupAddress address, String addressId) async {
    try {
      // Request location permission
      final permission = await Permission.location.request();
      
      if (permission.isDenied || permission.isPermanentlyDenied) {
        ToastService.show(
          context,
          "Location permission is required to get your current location",
          type: ToastType.error,
        );
        return;
      }
      
      // Check if location services are enabled
      // Wrap in try-catch in case geolocator plugin isn't properly linked
      bool serviceEnabled = false;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        debugPrint('Geolocator not available: $e');
        ToastService.show(
          context,
          "Location services not available. Please restart the app after installing updates.",
          type: ToastType.error,
        );
        return;
      }
      
      if (!serviceEnabled) {
        ToastService.show(
          context,
          "Please enable location services",
          type: ToastType.error,
        );
        return;
      }
      
      // Show loading indicator
      ToastService.show(
        context,
        "Getting your location...",
        type: ToastType.info,
      );
      
      // Get current position
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        debugPrint('Error getting position: $e');
        ToastService.show(
          context,
          "Failed to get location. Please try again or select location on map.",
          type: ToastType.error,
        );
        return;
      }
      
      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        // Normalize region name
        String? rawRegion = place.administrativeArea;
        String region = _normalizeRegionName(rawRegion);
        
        // Format address for display
        String formattedAddress = [
          place.thoroughfare,
          place.subLocality,
          place.locality,
          rawRegion,
          place.country,
        ].where((component) => component != null && component.isNotEmpty).join(', ');
        
        // Format address details (street address) - prioritize thoroughfare and subLocality
        String addressDetails = [
          place.thoroughfare,
          place.subLocality,
          place.locality,
        ].where((component) => component != null && component.isNotEmpty).join(', ');
        
        // If no thoroughfare, use subLocality or locality as fallback
        if (addressDetails.isEmpty) {
          addressDetails = place.subLocality ?? place.locality ?? formattedAddress;
        }
        
        // Get available zones for the region from JSON
        final locale = ref.read(localeProvider);
        final availableZones = await RegionsService.getZonesForGovernorate(
          region.isNotEmpty ? region : 'Cairo',
          locale.languageCode,
        );
        
        String? selectedZone = address.zone;
        
        // Try to match zone from GPS data with zones from JSON
        // Check multiple fields from Placemark to find the best match
        if (availableZones.isNotEmpty) {
          // Fields to check in order of priority
          final fieldsToCheck = <String>[];
          if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
            fieldsToCheck.add(place.subAdministrativeArea!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            fieldsToCheck.add(place.locality!);
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            fieldsToCheck.add(place.subLocality!);
          }
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
            fieldsToCheck.add(place.thoroughfare!);
          }
          
          for (final field in fieldsToCheck) {
            final fieldLower = field.toLowerCase().trim();
            
            // Try exact match first
            final exactMatch = availableZones.firstWhere(
              (zone) => zone.toLowerCase().trim() == fieldLower,
              orElse: () => '',
            );
            
            if (exactMatch.isNotEmpty) {
              selectedZone = exactMatch;
              break;
            }
            
            // Try contains match (partial match)
            final containsMatch = availableZones.firstWhere(
              (zone) {
                final zoneLower = zone.toLowerCase().trim();
                return zoneLower.contains(fieldLower) || fieldLower.contains(zoneLower);
              },
              orElse: () => '',
            );
            
            if (containsMatch.isNotEmpty) {
              selectedZone = containsMatch;
              break;
            }
            
            // Try word-by-word matching for compound names
            final fieldWords = fieldLower.split(RegExp(r'[\s\-_,]+'));
            for (final word in fieldWords) {
              if (word.length < 3) continue; // Skip very short words
              
              final wordMatch = availableZones.firstWhere(
                (zone) {
                  final zoneLower = zone.toLowerCase().trim();
                  return zoneLower.contains(word) || word.contains(zoneLower.split(' ').first);
                },
                orElse: () => '',
              );
              
              if (wordMatch.isNotEmpty) {
                selectedZone = wordMatch;
                break;
              }
            }
            
            if (selectedZone != address.zone) break;
          }
          
          debugPrint('GPS Zone matching - subAdministrativeArea: ${place.subAdministrativeArea}, locality: ${place.locality}, subLocality: ${place.subLocality}');
          debugPrint('Available zones count: ${availableZones.length}');
          debugPrint('Selected zone: $selectedZone');
        }
        
        // Normalize country name - only use if it's in our countries list
        String? normalizedCountry;
        if (place.country != null) {
          // Normalize country name (e.g., "Egypt" or "Arab Republic of Egypt" -> "Egypt")
          String countryLower = place.country!.toLowerCase();
          if (countryLower.contains('egypt') || countryLower == 'eg') {
            normalizedCountry = 'Egypt';
          } else if (countries.contains(place.country)) {
            normalizedCountry = place.country;
          }
          // Only set country if it's in our list
          if (normalizedCountry == null || !countries.contains(normalizedCountry)) {
            normalizedCountry = null; // Don't set invalid country
          }
        }
        
        // Ensure addressDetails is not empty - use formattedAddress as fallback
        final finalAddressDetails = addressDetails.isNotEmpty 
            ? addressDetails 
            : (formattedAddress.isNotEmpty ? formattedAddress : 'Address location');
        
        debugPrint('Setting addressDetails: $finalAddressDetails');
        debugPrint('Formatted address: $formattedAddress');
        debugPrint('Country from GPS: ${place.country}, Normalized: $normalizedCountry');
        
        // Update address with current location
        _updateAddress(addressId, address.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          formattedAddress: formattedAddress,
          addressDetails: finalAddressDetails,
          country: normalizedCountry ?? address.country, // Only set if valid, otherwise keep existing
          region: region.isNotEmpty ? region : address.region,
          zone: selectedZone,
        ));
        
        ToastService.show(
          context,
          "Location updated successfully",
          type: ToastType.success,
        );
      } else {
        // If no placemarks, still save coordinates
        _updateAddress(addressId, address.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
        ));
        
        ToastService.show(
          context,
          "Location saved (address not found)",
          type: ToastType.info,
        );
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      
      // Check if it's a MissingPluginException
      if (e.toString().contains('MissingPluginException')) {
        ToastService.show(
          context,
          "Please restart the app to enable location features",
          type: ToastType.error,
        );
      } else {
        ToastService.show(
          context,
          "Failed to get location: ${e.toString()}",
          type: ToastType.error,
        );
      }
    }
  }
  
  // Normalize region name to match dropdown options - always return Cairo
  String _normalizeRegionName(String? regionName) {
    // Always return Cairo as it's the only option
    return 'Cairo';
  }
  
  Future<void> _openLocationPicker(PickupAddress address, String addressId) async {
    final LocationData? result = await Navigator.push<LocationData>(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          initialLatitude: address.latitude,
          initialLongitude: address.longitude,
        ),
      ),
    );

    if (result != null) {
      // Normalize country - only use if it's in our countries list
      String? normalizedCountry;
      if (result.country != null) {
        String countryLower = result.country!.toLowerCase();
        if (countryLower.contains('egypt') || countryLower == 'eg') {
          normalizedCountry = 'Egypt';
        } else if (countries.contains(result.country)) {
          normalizedCountry = result.country;
        }
        // Only set country if it's in our list
        if (normalizedCountry == null || !countries.contains(normalizedCountry)) {
          normalizedCountry = null;
        }
      }
      
      // Load zones dynamically from JSON based on locale
      final locale = ref.read(localeProvider);
      final availableZones = await RegionsService.getZonesForGovernorate(
        result.region ?? 'Cairo',
        locale.languageCode,
      );
      
      String? selectedZone = address.zone;
      if (result.zone != null && result.zone!.isNotEmpty && availableZones.isNotEmpty) {
        // Try to match with an available zone
        if (availableZones.any((zone) => zone.toLowerCase().contains(result.zone!.toLowerCase()))) {
          selectedZone = availableZones.firstWhere(
            (zone) => zone.toLowerCase().contains(result.zone!.toLowerCase()),
            orElse: () => availableZones.first,
          );
        } else if (availableZones.isNotEmpty) {
          selectedZone = availableZones.first;
        }
      }
      
      // Extract address details from the map picker result
      String? addressDetailsToSet = result.addressDetails;
      if (addressDetailsToSet == null || addressDetailsToSet.isEmpty) {
        // Fallback to formatted address if addressDetails is empty
        addressDetailsToSet = result.formattedAddress ?? 'Selected location';
      }
      
      _updateAddress(addressId, address.copyWith(
        latitude: result.latitude,
        longitude: result.longitude,
        formattedAddress: result.formattedAddress,
        addressDetails: addressDetailsToSet,
        country: normalizedCountry ?? address.country, // Only set if valid
        region: result.region ?? address.region,
        zone: selectedZone,
      ));
    }
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

