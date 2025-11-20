import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/l10n/app_localizations.dart';
import '../../../../../core/services/regions_service.dart';
import '../../../../../core/providers/locale_provider.dart';

class CustomerDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>)? onCustomerDataSaved;

  const CustomerDetailsScreen({
    super.key,
    this.initialData,
    this.onCustomerDataSaved,
  });

  @override
  ConsumerState<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends ConsumerState<CustomerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _phoneController = TextEditingController(text: '');
  final TextEditingController _secondaryPhoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressDetailsController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  
  String _selectedCountryCode = '+20';
  String _selectedSecondaryCountryCode = '+20';
  String? _selectedCity;
  String? _selectedZone;
  bool _isWorkingAddress = false;
  
  // Get localized city name based on current locale
  String _getLocalizedCityName(String locale) {
    return locale == 'ar' ? 'القاهره' : 'Cairo';
  }
  
  // Get governorate name for API calls (always use localized version)
  String _getGovernorateNameForApi(String locale) {
    return locale == 'ar' ? 'القاهره' : 'Cairo';
  }

  @override
  void initState() {
    super.initState();
    
    // Default to localized Cairo name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = ref.read(localeProvider).languageCode;
      setState(() {
        _selectedCity = _getLocalizedCityName(locale);
      });
    });
    
    // Load initial data if provided (for editing existing customer)
    if (widget.initialData != null) {
      _loadInitialData();
    }
  }
  
  void _loadInitialData() {
    final data = widget.initialData!;
    
    // Extract country code and phone number
    if (data['phoneNumber'] != null) {
      final phoneNumber = data['phoneNumber'] as String;
      
      // For Egyptian numbers, we expect format like +201xxxxxxxxx
      if (phoneNumber.startsWith('+20')) {
        _selectedCountryCode = '+2';
        _phoneController.text = phoneNumber.substring(3);
      } 
      // For other international formats
      else if (phoneNumber.startsWith('+')) {
        // Just default to +2 and keep the entire number
        _selectedCountryCode = '+2';
        _phoneController.text = phoneNumber.substring(1);
      } 
      // No plus sign, just use the whole number
      else {
        _phoneController.text = phoneNumber;
      }
    }
    
    // Secondary phone
    if (data['secondaryPhone'] != null && data['secondaryPhone'].toString().isNotEmpty) {
      final secondaryPhone = data['secondaryPhone'] as String;
      
      // Extract country code and phone number for secondary phone
      if (secondaryPhone.startsWith('+20')) {
        _selectedSecondaryCountryCode = '+20';
        _secondaryPhoneController.text = secondaryPhone.substring(3);
      } else if (secondaryPhone.startsWith('+')) {
        _selectedSecondaryCountryCode = '+20';
        _secondaryPhoneController.text = secondaryPhone.substring(1);
      } else {
        _secondaryPhoneController.text = secondaryPhone;
      }
    }
    
    // Other fields
    _nameController.text = data['name'] ?? '';
    final locale = ref.read(localeProvider).languageCode;
    // If city is provided, use it; otherwise default to localized Cairo
    final cityFromData = data['city'];
    if (cityFromData != null && cityFromData.toString().isNotEmpty) {
      _selectedCity = cityFromData.toString();
    } else {
      _selectedCity = _getLocalizedCityName(locale);
    }
    _selectedZone = data['zone'];
    _addressDetailsController.text = data['addressDetails'] ?? '';
    _buildingController.text = data['building'] ?? '';
    _floorController.text = data['floor'] ?? '';
    _apartmentController.text = data['apartment'] ?? '';
    _landmarkController.text = data['landmark'] ?? '';
    _isWorkingAddress = data['isWorkingAddress'] ?? false;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _secondaryPhoneController.dispose();
    _nameController.dispose();
    _addressDetailsController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _saveCustomerDetails() {
    if (_formKey.currentState!.validate()) {
      // Create customer data object
      final customerData = {
        'phoneNumber': '$_selectedCountryCode${_phoneController.text}',
        'secondaryPhone': _secondaryPhoneController.text.isNotEmpty 
            ? '$_selectedSecondaryCountryCode${_secondaryPhoneController.text}' 
            : null,
        'name': _nameController.text,
        'city': _selectedCity ?? 'Cairo',
        'zone': _selectedZone,
        'addressDetails': _addressDetailsController.text,
        'building': _buildingController.text,
        'floor': _floorController.text,
        'apartment': _apartmentController.text,
        'landmark': _landmarkController.text,
        'isWorkingAddress': _isWorkingAddress,
      };
      
      // Call the callback if provided, otherwise return the data
      if (widget.onCustomerDataSaved != null) {
        widget.onCustomerDataSaved!(customerData);
      }
      
      // Return to previous screen
      Navigator.of(context).pop(customerData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).createNewOrder,
          style: const TextStyle(
            color: Color(0xff2F2F2F),
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xff2F2F2F)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear the form or implement any other action
              setState(() {
                _formKey.currentState?.reset();
                _phoneController.clear();
                _secondaryPhoneController.clear();
                _nameController.clear();
                _addressDetailsController.clear();
                _buildingController.clear();
                _floorController.clear();
                _apartmentController.clear();
                _landmarkController.clear();
                _selectedCity = null;
                _isWorkingAddress = false;
              });
            },
            child: Text(AppLocalizations.of(context).clear, style: const TextStyle(color: Colors.grey)),
          )
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).customerDetails,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff2F2F2F),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Phone number field
                _buildPhoneNumberField(),
                const SizedBox(height: 16),
                
                // Secondary phone field (always visible)
                _buildPhoneNumberField(isSecondary: true),
                
                const SizedBox(height: 16),
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).namePlaceholder,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterYourName;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Address section
                Text(
                  AppLocalizations.of(context).address,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff2F2F2F),
                  ),
                ),
                const SizedBox(height: 16),
                
                // City dropdown (Cairo only)
                _buildCityDropdown(),
                const SizedBox(height: 16),
                
                // Zone dropdown (shown when Cairo is selected - check both localized names)
                if (_selectedCity == 'Cairo' || _selectedCity == 'القاهره') _buildZoneDropdown(),
                if (_selectedCity == 'Cairo' || _selectedCity == 'القاهره') const SizedBox(height: 16),
                
                // Address details
                TextFormField(
                  controller: _addressDetailsController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).addressDetails,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterAddressDetails;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Building, Floor, Apartment in a row
                Row(
                  children: [
                    // Building
                    Expanded(
                      child: TextFormField(
                        controller: _buildingController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).building,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Floor
                    Expanded(
                      child: TextFormField(
                        controller: _floorController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).floor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Apartment
                    Expanded(
                      child: TextFormField(
                        controller: _apartmentController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).apartment,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Landmark
                TextFormField(
                  controller: _landmarkController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).landmark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Working address checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isWorkingAddress,
                      onChanged: (value) {
                        setState(() {
                          _isWorkingAddress = value ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).thisIsWorkingAddress,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xff2F2F2F),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.help_outline, size: 16, color: Colors.blue),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveCustomerDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue.shade200,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            AppLocalizations.of(context).save,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField({bool isSecondary = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Country code section (shown for both primary and secondary)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              isSecondary ? _selectedSecondaryCountryCode : _selectedCountryCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Add a vertical divider
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),
          
          // Phone number input
          Expanded(
            child: TextFormField(
              controller: isSecondary ? _secondaryPhoneController : _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              decoration: InputDecoration(
                hintText: isSecondary ? AppLocalizations.of(context).secondaryPhoneNumber : AppLocalizations.of(context).phoneNumber,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                counterText: '', // Hide the character counter
              ),
              validator: isSecondary
                  ? null // Secondary phone is optional
                  : (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).pleaseEnterYourPhoneNumber;
                      }
                      return null;
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer(
        builder: (context, ref, child) {
          final locale = ref.watch(localeProvider).languageCode;
          final localizedCityName = _getLocalizedCityName(locale);
          
          return DropdownButtonFormField<String>(
            value: _selectedCity ?? localizedCityName,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).cityArea,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.arrow_drop_down),
            isExpanded: true,
            items: [localizedCityName].map((String city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCity = newValue ?? localizedCityName;
                _selectedZone = null; // Reset zone when city changes
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context).pleaseSelectCity;
              }
              return null;
            },
          );
        },
      ),
    );
  }
  
  Widget _buildZoneDropdown() {
    final locale = ref.watch(localeProvider).languageCode;
    final governorateName = _getGovernorateNameForApi(locale);
    
    return ref.watch(zonesForGovernorateProvider(governorateName)).when(
      data: (availableZones) {
        if (availableZones.isEmpty) {
          return const SizedBox.shrink();
        }
        return InkWell(
          onTap: () => _showZoneSearchDialog(availableZones),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedZone ?? 'Zone',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedZone != null ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
  
  void _showZoneSearchDialog(List<String> zones) {
    final TextEditingController searchController = TextEditingController();
    List<String> filteredZones = List.from(zones);
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text(
                            'Select Zone',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
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
                          hintText: 'Search zone...',
                          prefixIcon: const Icon(Icons.search),
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
                            borderSide: const BorderSide(color: Colors.orange, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value.isEmpty) {
                              filteredZones = List.from(zones);
                            } else {
                              filteredZones = zones
                                  .where((zone) => zone.toLowerCase().contains(value.toLowerCase()))
                                  .toList();
                            }
                          });
                        },
                      ),
                    ),
                    // Zones list
                    Flexible(
                      child: filteredZones.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'No zones found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredZones.length,
                              itemBuilder: (context, index) {
                                final zone = filteredZones[index];
                                final isSelected = zone == _selectedZone;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedZone = zone;
                                    });
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: Container(
                                    color: isSelected ? Colors.orange.shade50 : Colors.transparent,
                                    child: ListTile(
                                      title: Text(
                                        zone,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          color: isSelected ? Colors.orange.shade900 : Colors.black87,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? const Icon(Icons.check, color: Colors.orange)
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (filteredZones.isNotEmpty)
                      const Divider(height: 1),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // This method is kept for backward compatibility but not used in this screen
  String _getLocalizedCityNameFromEnglish(BuildContext context, String englishCityName) {
    final l10n = AppLocalizations.of(context);
    switch (englishCityName) {
      case 'Cairo':
        return l10n.cairo;
      case 'Alexandria':
        return l10n.alexandria;
      case 'Giza':
        return l10n.giza;
      case 'Port Said':
        return l10n.portSaid;
      case 'Suez':
        return l10n.suez;
      case 'Luxor':
        return l10n.luxor;
      case 'Aswan':
        return l10n.aswan;
      case 'Hurghada':
        return l10n.hurghada;
      case 'Sharm El Sheikh':
        return l10n.sharmElSheikh;
      default:
        return englishCityName;
    }
  }
}