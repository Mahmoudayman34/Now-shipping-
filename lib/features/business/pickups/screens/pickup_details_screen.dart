import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:now_shipping/features/business/pickups/models/pickup_model.dart';
import 'package:now_shipping/features/business/pickups/screens/create_pickup_screen.dart';
import '../../../../core/utils/responsive_utils.dart';

class PickupDetailsScreen extends StatefulWidget {
  final PickupModel pickup;

  const PickupDetailsScreen({
    super.key,
    required this.pickup,
  });

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

    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            'Pickup Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xff2F2F2F),
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
              Icons.arrow_back_ios,
              color: const Color(0xff2F2F2F),
              size: ResponsiveUtils.getResponsiveIconSize(context),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            // Edit button
            IconButton(
              icon: Icon(
                Icons.edit,
                color: const Color(0xFF26A2B9),
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
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
              margin: ResponsiveUtils.getResponsivePadding(context),
              padding: ResponsiveUtils.getResponsivePadding(context),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context),
                ),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    isPickedUp ? Icons.check_circle : Icons.local_shipping_outlined,
                    color: statusColor,
                    size: ResponsiveUtils.getResponsiveIconSize(context) * 1.2,
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pickup.status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                      Text(
                        isPickedUp ? 'Your pickup has been completed' : 'Your pickup is scheduled',
                        style: TextStyle(
                          color: statusColor.withOpacity(0.8),
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
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
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: spacing,
        right: spacing,
        bottom: spacing,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
            padding: EdgeInsets.all(spacing),
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
                fontWeight: FontWeight.w600,
                color: const Color(0xff2F2F2F),
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
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context);
    
    return Padding(
      padding: EdgeInsets.all(spacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: iconSize),
            SizedBox(width: spacing * 0.67),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
                color: const Color(0xff2F2F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return Container(
      padding: EdgeInsets.all(spacing),
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
                padding: EdgeInsets.symmetric(vertical: spacing),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: Text(
                'Edit Pickup',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
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