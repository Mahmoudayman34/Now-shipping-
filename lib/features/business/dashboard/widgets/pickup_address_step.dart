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
import '../../../../core/l10n/app_localizations.dart';

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
  
  // Text editing controllers for each address - keyed by address ID
  final Map<String, TextEditingController> _addressNameControllers = {};
  final Map<String, TextEditingController> _addressDetailsControllers = {};
  final Map<String, TextEditingController> _nearbyLandmarkControllers = {};
  final Map<String, TextEditingController> _phoneNumberControllers = {};
  final Map<String, TextEditingController> _otherPhoneControllers = {};
  
  // Search controllers for zone search dialogs - keyed by address ID
  final Map<String, TextEditingController> _zoneSearchControllers = {};
  
  // Countries list - will be translated
  List<String> getCountries(BuildContext context) {
    return [AppLocalizations.of(context).egypt];
  }
  
  // Zones are now loaded dynamically from JSON files via RegionsService
  
  @override
  void initState() {
    super.initState();
    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadExistingData();
    });
    
    // Register save callback
    if (widget.onRegisterSave != null) {
      widget.onRegisterSave!(_saveFormData);
    }
  }
  
  @override
  void dispose() {
    // Dispose all text controllers
    for (var controller in _addressNameControllers.values) {
      controller.dispose();
    }
    for (var controller in _addressDetailsControllers.values) {
      controller.dispose();
    }
    for (var controller in _nearbyLandmarkControllers.values) {
      controller.dispose();
    }
    for (var controller in _phoneNumberControllers.values) {
      controller.dispose();
    }
    for (var controller in _otherPhoneControllers.values) {
      controller.dispose();
    }
    for (var controller in _zoneSearchControllers.values) {
      controller.dispose();
    }
    _addressNameControllers.clear();
    _addressDetailsControllers.clear();
    _nearbyLandmarkControllers.clear();
    _phoneNumberControllers.clear();
    _otherPhoneControllers.clear();
    _zoneSearchControllers.clear();
    super.dispose();
  }
  
  // Initialize controllers for an address
  void _initializeControllersForAddress(String addressId, PickupAddress address) {
    // Address name controller
    if (!_addressNameControllers.containsKey(addressId)) {
      _addressNameControllers[addressId] = TextEditingController(text: address.addressName ?? '');
    } else {
      // Update text if it changed externally
      if (_addressNameControllers[addressId]!.text != (address.addressName ?? '')) {
        _addressNameControllers[addressId]!.text = address.addressName ?? '';
      }
    }
    
    // Address details controller
    if (!_addressDetailsControllers.containsKey(addressId)) {
      _addressDetailsControllers[addressId] = TextEditingController(text: address.addressDetails ?? '');
    } else {
      if (_addressDetailsControllers[addressId]!.text != (address.addressDetails ?? '')) {
        _addressDetailsControllers[addressId]!.text = address.addressDetails ?? '';
      }
    }
    
    // Nearby landmark controller
    if (!_nearbyLandmarkControllers.containsKey(addressId)) {
      _nearbyLandmarkControllers[addressId] = TextEditingController(text: address.nearbyLandmark ?? '');
    } else {
      if (_nearbyLandmarkControllers[addressId]!.text != (address.nearbyLandmark ?? '')) {
        _nearbyLandmarkControllers[addressId]!.text = address.nearbyLandmark ?? '';
      }
    }
    
    // Phone number controller
    if (!_phoneNumberControllers.containsKey(addressId)) {
      _phoneNumberControllers[addressId] = TextEditingController(text: address.phoneNumber ?? '');
    } else {
      if (_phoneNumberControllers[addressId]!.text != (address.phoneNumber ?? '')) {
        _phoneNumberControllers[addressId]!.text = address.phoneNumber ?? '';
      }
    }
    
    // Other phone controller
    if (!_otherPhoneControllers.containsKey(addressId)) {
      _otherPhoneControllers[addressId] = TextEditingController(text: address.otherPhoneNumber ?? '');
    } else {
      if (_otherPhoneControllers[addressId]!.text != (address.otherPhoneNumber ?? '')) {
        _otherPhoneControllers[addressId]!.text = address.otherPhoneNumber ?? '';
      }
    }
  }
  
  // Dispose controllers for an address
  void _disposeControllersForAddress(String addressId) {
    _addressNameControllers[addressId]?.dispose();
    _addressDetailsControllers[addressId]?.dispose();
    _nearbyLandmarkControllers[addressId]?.dispose();
    _phoneNumberControllers[addressId]?.dispose();
    _otherPhoneControllers[addressId]?.dispose();
    _addressNameControllers.remove(addressId);
    _addressDetailsControllers.remove(addressId);
    _nearbyLandmarkControllers.remove(addressId);
    _phoneNumberControllers.remove(addressId);
    _otherPhoneControllers.remove(addressId);
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

  Future<void> _loadExistingData() async {
    final data = ref.read(profileFormDataProvider);
    // Get Cairo name for default region
    final locale = ref.read(localeProvider);
    final cairoName = await RegionsService.getCairoGovernorateName(locale.languageCode);
    
    // Try to load new format first (list of addresses)
    if (data.containsKey('pickupAddresses') && data['pickupAddresses'] != null) {
      final List<dynamic> addressesList = data['pickupAddresses'] as List<dynamic>;
      setState(() {
        _addresses = addressesList
            .map((json) {
              final address = PickupAddress.fromJson(json as Map<String, dynamic>);
              // Set default values if not present
              return address.copyWith(
                country: address.country ?? AppLocalizations.of(context).egypt,
                region: address.region ?? cairoName, // Default to Cairo from JSON
              );
            })
            .toList();
        
        // Initialize form keys and controllers for each address
        for (var address in _addresses) {
          if (address.id != null) {
            _addressFormKeys[address.id!] = GlobalKey<FormState>();
            _initializeControllersForAddress(address.id!, address);
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
        country: data['country'] ?? AppLocalizations.of(context).egypt, // Default to Egypt
        region: data['region'] ?? data['city'], // Don't set default - will be loaded from JSON
        zone: data['zone'],
        latitude: data['latitude']?.toDouble(),
        longitude: data['longitude']?.toDouble(),
        formattedAddress: data['formattedAddress'] ?? data['pickupLocationString'],
      );
      
      setState(() {
        _addresses = [address];
        if (address.id != null) {
          _addressFormKeys[address.id!] = GlobalKey<FormState>();
          _initializeControllersForAddress(address.id!, address);
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
              country: address.country ?? AppLocalizations.of(context).egypt,
              region: address.region ?? cairoName, // Default to Cairo from JSON
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
    // Get Cairo name based on current locale
    final locale = ref.read(localeProvider);
    // Use temporary Cairo name based on locale, will be updated when async completes
    final tempCairoName = locale.languageCode == 'ar' ? 'القاهره' : 'Cairo';
    
    final tempAddress = PickupAddress(
      id: newId,
      addressName: addressNumber == 1 ? 'Main Address' : 'Address $addressNumber',
      country: AppLocalizations.of(context).egypt, // Auto-select Egypt
      region: tempCairoName, // Temporary Cairo name
    );
    
    setState(() {
      _addresses.add(tempAddress);
      _addressFormKeys[newId] = GlobalKey<FormState>();
      _initializeControllersForAddress(newId, tempAddress);
      // Expand newly added address by default
      _expandedAddresses.add(newId);
    });
    
    // Update with correct Cairo name from JSON
    RegionsService.getCairoGovernorateName(locale.languageCode).then((cairoName) {
      if (mounted) {
        final index = _addresses.indexWhere((addr) => addr.id == newId);
        if (index != -1) {
          setState(() {
            _addresses[index] = _addresses[index].copyWith(region: cairoName);
          });
          _saveFormData();
        }
      }
    });
    
    _saveFormData();
  }

  void _removeAddress(String addressId) {
      _disposeControllersForAddress(addressId);
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
        
        // Sync controller text if address changed externally (not from text field)
        // Only update if the value actually changed to avoid disrupting user input
        if (_addressNameControllers.containsKey(addressId)) {
          if (_addressNameControllers[addressId]!.text != (updatedAddress.addressName ?? '')) {
            _addressNameControllers[addressId]!.text = updatedAddress.addressName ?? '';
          }
        }
        if (_addressDetailsControllers.containsKey(addressId)) {
          if (_addressDetailsControllers[addressId]!.text != (updatedAddress.addressDetails ?? '')) {
            _addressDetailsControllers[addressId]!.text = updatedAddress.addressDetails ?? '';
          }
        }
        if (_nearbyLandmarkControllers.containsKey(addressId)) {
          if (_nearbyLandmarkControllers[addressId]!.text != (updatedAddress.nearbyLandmark ?? '')) {
            _nearbyLandmarkControllers[addressId]!.text = updatedAddress.nearbyLandmark ?? '';
          }
        }
        if (_phoneNumberControllers.containsKey(addressId)) {
          if (_phoneNumberControllers[addressId]!.text != (updatedAddress.phoneNumber ?? '')) {
            _phoneNumberControllers[addressId]!.text = updatedAddress.phoneNumber ?? '';
          }
        }
        if (_otherPhoneControllers.containsKey(addressId)) {
          if (_otherPhoneControllers[addressId]!.text != (updatedAddress.otherPhoneNumber ?? '')) {
            _otherPhoneControllers[addressId]!.text = updatedAddress.otherPhoneNumber ?? '';
          }
        }
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
        AppLocalizations.of(context).pleaseFillAllFields,
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
        AppLocalizations.of(context).pleaseAddCompleteAddress,
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
                            AppLocalizations.of(context).pickupLocations,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xffF29620),
              ),
            ),
                          const SizedBox(height: 4),
            Text(
                            AppLocalizations.of(context).pickupLocationsHelper,
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
                        AppLocalizations.of(context).noAddressesAdded,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).tapToAddFirstAddress,
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
                  AppLocalizations.of(context).progressAutoSaved,
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
    // Initialize controller if it doesn't exist
    if (!_addressNameControllers.containsKey(addressId)) {
      _initializeControllersForAddress(addressId, address);
    }
    final addressNameController = _addressNameControllers[addressId]!;
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
                            hintText: AppLocalizations.of(context).addressName,
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
    // Initialize controllers if they don't exist
    if (!_addressDetailsControllers.containsKey(addressId)) {
      _initializeControllersForAddress(addressId, address);
    }
    
    // Use stored controllers instead of creating new ones
    final addressDetailsController = _addressDetailsControllers[addressId]!;
    final nearbyLandmarkController = _nearbyLandmarkControllers[addressId]!;
    final phoneNumberController = _phoneNumberControllers[addressId]!;
    final otherPhoneController = _otherPhoneControllers[addressId]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).country,
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
                hint: Text(AppLocalizations.of(context).selectCountry),
                value: address.country != null && getCountries(context).contains(address.country) 
                    ? address.country 
                    : AppLocalizations.of(context).egypt, // Default to Egypt
                items: getCountries(context)
                    .map((country) => DropdownMenuItem(value: country, child: Text(country)))
                    .toList(),
                onChanged: (value) {
                    _updateAddress(addressId, address.copyWith(
                      country: value ?? AppLocalizations.of(context).egypt, // Default to Egypt if null
                      region: null, // Reset region when country changes - will be loaded from JSON
                      zone: null, // Reset zone when country changes
                    ));
                },
                validator: (value) => value == null ? AppLocalizations.of(context).pleaseSelectCountry : null,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),

        // Governorate and Area dropdown - limited to Cairo only
        if (address.country != null)
          ref.watch(cairoOnlyProvider).when(
            data: (governorates) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).governorateAndArea,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).clickToSelectGovernorate,
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
                      hint: Text(AppLocalizations.of(context).selectArea),
                      value: address.region != null && governorates.contains(address.region)
                          ? address.region 
                          : governorates.isNotEmpty ? governorates.first : null,
                      items: governorates
                          .map((region) => DropdownMenuItem(value: region, child: Text(region)))
                          .toList(),
                      onChanged: (value) {
                        _updateAddress(addressId, address.copyWith(
                          region: value,
                          zone: null, // Reset zone when region changes
                        ));
                      },
                      validator: (value) => value == null ? AppLocalizations.of(context).pleaseSelectGovernorate : null,
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
            error: (error, stack) => Text(
              'Error loading governorates: $error',
              style: TextStyle(color: theme.colorScheme.error),
            ),
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
                AppLocalizations.of(context).zone,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showZoneSearchDialog(context, address, addressId, availableZones),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.zone ?? AppLocalizations.of(context).selectZone,
                          style: TextStyle(
                            color: address.zone != null 
                                ? Colors.black87 
                                : Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
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
          key: ValueKey('addressDetails_${address.id}'),
          label: AppLocalizations.of(context).addressDetails,
          controller: addressDetailsController,
          hintText: AppLocalizations.of(context).addressDetailsHint,
          validator: Validators.required,
          onChanged: (value) {
            _updateAddress(addressId, address.copyWith(addressDetails: value));
          },
        ),
        
        const SizedBox(height: 16),
        
        // Nearby Landmark
        AppTextField(
          label: AppLocalizations.of(context).nearbyLandmark,
          controller: nearbyLandmarkController,
          hintText: AppLocalizations.of(context).nearbyLandmarkHint,
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
              AppLocalizations.of(context).pickupPhoneNumber,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                //hintText: AppLocalizations.of(context).pickupPhoneHint,
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
              AppLocalizations.of(context).otherPickupPhone,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: otherPhoneController,
              decoration: InputDecoration(
                //hintText: AppLocalizations.of(context).pickupPhoneHint,
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
          AppLocalizations.of(context).locationOnMap,
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
            label: Text(AppLocalizations.of(context).getLocation),
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
                          AppLocalizations.of(context).tapToSelectLocation,
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
                          AppLocalizations.of(context).locationSelected,
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
                            AppLocalizations.of(context).tapToChangeLocation,
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
          AppLocalizations.of(context).locationPermissionRequired,
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
          AppLocalizations.of(context).locationServicesNotAvailable,
          type: ToastType.error,
        );
        return;
      }
      
      if (!serviceEnabled) {
        ToastService.show(
          context,
          AppLocalizations.of(context).pleaseEnableLocationServices,
          type: ToastType.error,
        );
        return;
      }
      
      // Show loading indicator
      ToastService.show(
        context,
        AppLocalizations.of(context).gettingYourLocation,
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
          AppLocalizations.of(context).failedToGetLocation,
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
        
        // Get region from placemark for address formatting
        String? rawRegion = place.administrativeArea;
        
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
        
        // Get available zones for Cairo from JSON
        final locale = ref.read(localeProvider);
        // Always use Cairo governorate
        final cairoGovernorateName = await RegionsService.getCairoGovernorateName(locale.languageCode);
        final availableZones = await RegionsService.getZonesForGovernorate(
          cairoGovernorateName,
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
        
        // Normalize country name - only use if it's Egypt
        String? normalizedCountry;
        if (place.country != null) {
          // Normalize country name (e.g., "Egypt" or "Arab Republic of Egypt" -> "Egypt")
          String countryLower = place.country!.toLowerCase();
          if (countryLower.contains('egypt') || countryLower == 'eg') {
            normalizedCountry = AppLocalizations.of(context).egypt;
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
        // Always set region to Cairo
        _updateAddress(addressId, address.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          formattedAddress: formattedAddress,
          addressDetails: finalAddressDetails,
          country: normalizedCountry ?? address.country ?? AppLocalizations.of(context).egypt, // Only set if valid, otherwise keep existing
          region: cairoGovernorateName, // Always set to Cairo
          zone: selectedZone,
        ));
        
        ToastService.show(
          context,
          AppLocalizations.of(context).locationUpdatedSuccessfully,
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
          AppLocalizations.of(context).locationSaved,
          type: ToastType.info,
        );
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      
      // Check if it's a MissingPluginException
      if (e.toString().contains('MissingPluginException')) {
        ToastService.show(
          context,
          AppLocalizations.of(context).pleaseRestartApp,
          type: ToastType.error,
        );
      } else {
        ToastService.show(
          context,
          AppLocalizations.of(context).failedToGetLocationError(e.toString()),
          type: ToastType.error,
        );
      }
    }
  }
  
  // Show searchable zone dialog
  void _showZoneSearchDialog(BuildContext context, PickupAddress address, String addressId, List<String> availableZones) {
    // Initialize search controller for this address if not exists
    if (!_zoneSearchControllers.containsKey(addressId)) {
      _zoneSearchControllers[addressId] = TextEditingController();
    }
    final searchController = _zoneSearchControllers[addressId]!;
    List<String> filteredZones = List.from(availableZones);
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.themeColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).selectZone,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Search field
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).searchZone,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: searchController,
                            builder: (context, value, child) {
                              return value.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () {
                                        searchController.clear();
                                        setDialogState(() {
                                          filteredZones = List.from(availableZones);
                                        });
                                      },
                                    )
                                  : const SizedBox.shrink();
                            },
                          ),
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
                            borderSide: BorderSide(color: widget.themeColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value.isEmpty) {
                              filteredZones = List.from(availableZones);
                            } else {
                              filteredZones = availableZones
                                  .where((zone) => zone.toLowerCase().contains(value.toLowerCase()))
                                  .toList();
                            }
                          });
                        },
                      ),
                    ),
                    // Zones list
                    Expanded(
                      child: filteredZones.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  AppLocalizations.of(context).noZonesFound,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredZones.length,
                              itemBuilder: (context, index) {
                                final zone = filteredZones[index];
                                final isSelected = zone == address.zone;
                                return InkWell(
                                  onTap: () {
                                    _updateAddress(addressId, address.copyWith(zone: zone));
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: Container(
                                    color: isSelected 
                                        ? widget.themeColor.withOpacity(0.1) 
                                        : Colors.transparent,
                                    child: ListTile(
                                      title: Text(
                                        zone,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          color: isSelected 
                                              ? widget.themeColor 
                                              : Colors.black87,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? Icon(Icons.check, color: widget.themeColor)
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
      // Normalize country - only use if it's Egypt
      String? normalizedCountry;
      if (result.country != null) {
        String countryLower = result.country!.toLowerCase();
        if (countryLower.contains('egypt') || countryLower == 'eg') {
          normalizedCountry = AppLocalizations.of(context).egypt;
        }
      }
      
      // Load zones dynamically from JSON based on locale - always use Cairo
      final locale = ref.read(localeProvider);
      // Always use Cairo governorate
      final cairoGovernorateName = await RegionsService.getCairoGovernorateName(locale.languageCode);
      final availableZones = await RegionsService.getZonesForGovernorate(
        cairoGovernorateName,
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
      
      // Always set region to Cairo
      _updateAddress(addressId, address.copyWith(
        latitude: result.latitude,
        longitude: result.longitude,
        formattedAddress: result.formattedAddress,
        addressDetails: addressDetailsToSet,
        country: normalizedCountry ?? address.country ?? AppLocalizations.of(context).egypt, // Only set if valid
        region: cairoGovernorateName, // Always set to Cairo
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
            child: Text(
              AppLocalizations.of(context).back,
              style: const TextStyle(
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
            child: Text(
              AppLocalizations.of(context).next,
              style: const TextStyle(
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

