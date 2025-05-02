import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tes1/features/business/pickups/models/pickup_model.dart';
import 'package:tes1/features/business/pickups/widgets/special_requirement_card.dart';

class CreatePickupScreen extends StatefulWidget {
  final PickupModel? pickupToEdit; // Added parameter for pickup to edit

  const CreatePickupScreen({super.key, this.pickupToEdit});

  @override
  State<CreatePickupScreen> createState() => _CreatePickupScreenState();
}

class _CreatePickupScreenState extends State<CreatePickupScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  bool _isFragileItem = false;
  bool _isLargeItem = false;
  bool _isEditing = false; // Flag to track if we're in edit mode

  final _ordersController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _notesController = TextEditingController();

  // Initialize directly instead of using late initialization
  final List<DateTime> _quickSelectDates = List.generate(
    5,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  @override
  void initState() {
    super.initState();
    // Populate fields if we're editing an existing pickup
    if (widget.pickupToEdit != null) {
      _isEditing = true;
      _pickupAddressController.text = widget.pickupToEdit!.address;
      _contactNumberController.text =
          widget.pickupToEdit!.contactNumber.replaceAll('+20', ''); // Remove country code
      _notesController.text = widget.pickupToEdit!.notes ?? '';
      _selectedDate = widget.pickupToEdit!.pickupDate;
      _isFragileItem = widget.pickupToEdit!.isFragileItem ?? false;
      _isLargeItem = widget.pickupToEdit!.isLargeItem ?? false;
      // Assuming 1 order for now, in a real app you might want to store this in the pickup model
      _ordersController.text = '1';
    }
  }

  @override
  void dispose() {
    _ordersController.dispose();
    _pickupAddressController.dispose();
    _contactNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Text(
              _isEditing ? 'Edit PickUP' : 'Create PickUP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff2F2F2F),
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff2F2F2F)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _formKey.currentState?.reset();
                _ordersController.clear();
                _pickupAddressController.clear();
                _contactNumberController.clear();
                _notesController.clear();
                _selectedDate = null;
                _isFragileItem = false;
                _isLargeItem = false;
              });
            },
            child: const Text('Clear', style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pickup Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2F2F2F),
                ),
              ),
              const SizedBox(height: 20),

              // Number of Orders
              _buildFieldLabel('Number of Orders', isRequired: true),
              _buildTextField(
                controller: _ordersController,
                hintText: 'Enter number of orders',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Place of Pickup
              _buildFieldLabel('Place of Pickup', isRequired: true),
              _buildAddressField(
                controller: _pickupAddressController,
                hintText: 'Enter pickup address',
              ),
              _buildInfoText('Your saved pickup address will be used for this order.'),
              const SizedBox(height: 24),

              // Contact Info
              _buildFieldLabel('Contact Info', isRequired: true),
              _buildPhoneNumberField(),
              _buildInfoText('Please ensure this number is available on WhatsApp for delivery updates.'),
              const SizedBox(height: 24),

              // Enhanced Pick Up Date
              _buildFieldLabel('Pick Up Date', isRequired: true),
              _buildEnhancedDatePicker(),
              const SizedBox(height: 24),

              // Pickup Notes
              const Text(
                'Pickup Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff2F2F2F),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Enter any special instructions or notes for the pickup',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Options
              const Text(
                'Special Requirements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff2F2F2F),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SpecialRequirementCard(title: 'Fragile\nItem', subtitle: 'Special handling required', icon: Icons.warning_amber_rounded, isSelected: _isFragileItem, onTap: () => setState(() => _isFragileItem = !_isFragileItem)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SpecialRequirementCard(title: 'Large\nItem', subtitle: 'Requires larger vehicle', icon: Icons.local_shipping, isSelected: _isLargeItem, onTap: () => setState(() => _isLargeItem = !_isLargeItem)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _submitPickup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF89C29),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Save Changes' : 'Create',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced date picker widget
  Widget _buildEnhancedDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick select date cards
        SizedBox(
          height: 130, // Increased height to accommodate the content
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _quickSelectDates.length + 1, // Add one for the calendar option
            itemBuilder: (context, index) {
              // Last item is the calendar button
              if (index == _quickSelectDates.length) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildCalendarButton(),
                );
              }

              final date = _quickSelectDates[index];
              final bool isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildDateCard(date, isSelected),
              );
            },
          ),
        ),

        // Show selected date text
        if (_selectedDate != null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade400, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Pickup Date: ${DateFormat('EEEE, MMMM d, y').format(_selectedDate!)}',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Individual date card for quick select
  Widget _buildDateCard(DateTime date, bool isSelected) {
    final bool isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    final dayName = DateFormat('E').format(date); // Mon, Tue, etc.
    final dayNumber = date.day.toString();
    final month = DateFormat('MMM').format(date); // Jan, Feb, etc.

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF89C29) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF89C29) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use minimum space needed
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.normal,
                fontSize: 12,
                height: 1.2, // Reduce line height
              ),
            ),
            const SizedBox(height: 4), // Reduced spacing
            Text(
              dayNumber,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                height: 1.2, // Reduce line height
              ),
            ),
            const SizedBox(height: 2), // Reduced spacing
            Text(
              month,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.normal,
                fontSize: 12,
                height: 1.2, // Reduce line height
              ),
            ),
            if (isToday)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), // Reduced vertical padding
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : const Color(0xFFF89C29).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFF89C29),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.0, // Reduced line height
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Calendar button to open date picker dialog
  Widget _buildCalendarButton() {
    return GestureDetector(
      onTap: _openDatePickerDialog,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              color: Colors.blue.shade400,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              'Calendar',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Open the standard date picker dialog
  Future<void> _openDatePickerDialog() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF89C29), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Calendar text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF89C29), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff2F2F2F),
            ),
          ),
          if (isRequired)
            Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Country code section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Text(
              '+20',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Phone number input
          Expanded(
            child: TextFormField(
              controller: _contactNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter phone number',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, top: 4.0),
      child: Row(
        children: [
          Icon(
            text.contains('WhatsApp') ? Icons.phone : Icons.location_on_outlined,
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitPickup() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a pickup date')),
        );
        return;
      }

      // Create the updated or new pickup model
      final pickup = PickupModel(
        pickupId: _isEditing
            ? widget.pickupToEdit!.pickupId
            : DateTime.now().millisecondsSinceEpoch.toString(),
        address: _pickupAddressController.text,
        contactNumber: '+20${_contactNumberController.text}',
        pickupDate: _selectedDate!,
        status: _isEditing ? widget.pickupToEdit!.status : 'Upcoming',
        isFragileItem: _isFragileItem,
        isLargeItem: _isLargeItem,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      // Return the pickup to the previous screen
      Navigator.pop(context, pickup);
    }
  }
}
