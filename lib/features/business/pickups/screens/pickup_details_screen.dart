import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tes1/features/business/pickups/models/pickup_model.dart';
import 'package:tes1/features/business/pickups/screens/create_pickup_screen.dart';

class PickupDetailsScreen extends StatefulWidget {
  final PickupModel pickup;

  const PickupDetailsScreen({
    Key? key,
    required this.pickup,
  }) : super(key: key);

  @override
  State<PickupDetailsScreen> createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends State<PickupDetailsScreen> {
  late PickupModel _pickup;

  @override
  void initState() {
    super.initState();
    _pickup = widget.pickup;
  }

  @override
  Widget build(BuildContext context) {
    // Determine status color
    final bool isPickedUp = _pickup.status == 'Picked Up';
    final Color statusColor = isPickedUp ? Colors.green : const Color(0xFFF89C29);
    final String formattedDate = DateFormat('EEEE, MMMM d, y').format(_pickup.pickupDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pickup Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2F2F2F),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff2F2F2F)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF26A2B9)),
            onPressed: () => _navigateToEditScreen(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    isPickedUp ? Icons.check_circle : Icons.local_shipping_outlined,
                    color: statusColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pickup.status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        isPickedUp ? 'Your pickup has been completed' : 'Your pickup is scheduled',
                        style: TextStyle(
                          color: statusColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Pickup Details
            _buildDetailSection(
              'Pickup Information',
              [
                _buildDetailItem('Pickup ID', '#${_pickup.pickupId}'),
                _buildDetailItem('Scheduled Date', formattedDate),
                _buildDetailItem('Status', _pickup.status),
              ],
            ),

            // Address & Contact
            _buildDetailSection(
              'Address & Contact',
              [
                _buildDetailItem('Address', _pickup.address),
                _buildDetailItem('Contact Number', _pickup.contactNumber),
              ],
            ),

            // Special Requirements
            if (_pickup.isFragileItem || _pickup.isLargeItem)
              _buildDetailSection(
                'Special Requirements',
                [
                  if (_pickup.isFragileItem)
                    _buildDetailItem(
                      'Fragile Item', 
                      'This pickup contains fragile items that require special handling',
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.orange,
                    ),
                  if (_pickup.isLargeItem)
                    _buildDetailItem(
                      'Large Item', 
                      'This pickup contains large items that may require a larger vehicle',
                      icon: Icons.local_shipping,
                      iconColor: Colors.blue,
                    ),
                ],
              ),

            // Notes
            if (_pickup.notes != null && _pickup.notes!.isNotEmpty)
              _buildDetailSection(
                'Notes',
                [
                  _buildDetailItem('Special Instructions', _pickup.notes!),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: _pickup.status == 'Upcoming'
          ? _buildBottomActionBar()
          : null,
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xff2F2F2F),
              ),
            ),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff2F2F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _navigateToEditScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF89C29),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Edit Pickup',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen() async {
    // Navigate to edit screen and handle the result
    final updatedPickup = await Navigator.push<PickupModel>(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePickupScreen(pickupToEdit: _pickup),
      ),
    );
    
    // Update the pickup if changes were made
    if (updatedPickup != null) {
      setState(() {
        _pickup = updatedPickup;
      });
      
      // Pass the updated pickup back to the previous screen
      Navigator.pop(context, updatedPickup);
    }
  }
}