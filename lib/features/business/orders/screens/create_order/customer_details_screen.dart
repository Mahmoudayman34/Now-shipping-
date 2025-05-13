import 'package:flutter/material.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>)? onCustomerDataSaved;

  const CustomerDetailsScreen({
    super.key,
    this.initialData,
    this.onCustomerDataSaved,
  });

  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
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
  String? _selectedCity;
  bool _isWorkingAddress = false;
  bool _showSecondaryPhone = false;
  
  // City options for dropdown
  final List<String> _cities = [
    'Cairo', 
    'Alexandria', 
    'Giza', 
    'Port Said', 
    'Suez',
    'Luxor',
    'Aswan',
    'Hurghada',
    'Sharm El Sheikh'
  ];

  @override
  void initState() {
    super.initState();
    
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
        _selectedCountryCode = '+20';
        _phoneController.text = phoneNumber.substring(3);
      } 
      // For other international formats
      else if (phoneNumber.startsWith('+')) {
        // Just default to +20 and keep the entire number
        _selectedCountryCode = '+20';
        _phoneController.text = phoneNumber.substring(1);
      } 
      // No plus sign, just use the whole number
      else {
        _phoneController.text = phoneNumber;
      }
    }
    
    // Secondary phone
    if (data['secondaryPhone'] != null && data['secondaryPhone'].toString().isNotEmpty) {
      _secondaryPhoneController.text = data['secondaryPhone'];
      _showSecondaryPhone = true;
    }
    
    // Other fields
    _nameController.text = data['name'] ?? '';
    _selectedCity = data['city'];
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
        'secondaryPhone': _showSecondaryPhone ? _secondaryPhoneController.text : null,
        'name': _nameController.text,
        'city': _selectedCity,
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
        title: const Text(
          'Create new order',
          style: TextStyle(
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
            child: const Text('Clear', style: TextStyle(color: Colors.grey)),
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
                const Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff2F2F2F),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Phone number field
                _buildPhoneNumberField(),
                const SizedBox(height: 12),
                
                // "Add secondary number" button/link
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showSecondaryPhone = !_showSecondaryPhone;
                    });
                  },
                  child: Text(
                    _showSecondaryPhone 
                        ? 'Hide secondary number' 
                        : 'Add secondary number',
                    style: TextStyle(
                      color: Colors.teal.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Secondary phone field (conditionally shown)
                if (_showSecondaryPhone) ...[
                  const SizedBox(height: 16),
                  _buildPhoneNumberField(isSecondary: true),
                ],
                
                const SizedBox(height: 16),
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'name',
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
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Address section
                const Text(
                  'Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff2F2F2F),
                  ),
                ),
                const SizedBox(height: 16),
                
                // City dropdown
                _buildCityDropdown(),
                const SizedBox(height: 16),
                
                // Address details
                TextFormField(
                  controller: _addressDetailsController,
                  decoration: InputDecoration(
                    hintText: 'Address details',
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
                      return 'Please enter address details';
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
                          hintText: 'Building',
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
                          hintText: 'Floor',
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
                          hintText: 'Apartment',
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
                    hintText: 'Landmark',
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
                    const Text(
                      'This is working address',
                      style: TextStyle(
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
          child: const Text(
            'Save',
            style: TextStyle(
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
          // Country code section
          if (!isSecondary) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _selectedCountryCode,
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
          ],
          
          // Phone number input
          Expanded(
            child: TextFormField(
              controller: isSecondary ? _secondaryPhoneController : _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: isSecondary ? 'Secondary Phone Number' : 'Phone Number',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              validator: isSecondary
                  ? null // Secondary phone is optional
                  : (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
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
      child: DropdownButtonFormField<String>(
        value: _selectedCity,
        decoration: const InputDecoration(
          hintText: 'City - Area',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        icon: const Icon(Icons.arrow_drop_down),
        isExpanded: true,
        items: _cities.map((String city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCity = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a city';
          }
          return null;
        },
      ),
    );
  }
}