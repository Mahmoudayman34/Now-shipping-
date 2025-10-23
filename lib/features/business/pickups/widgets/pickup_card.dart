import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/pickup_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/pickup_details_tabbed_screen.dart';
import '../../../../core/utils/responsive_utils.dart';

class PickupCard extends StatelessWidget {
  final PickupModel pickup;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PickupCard({
    super.key,
    required this.pickup,
    this.onTap,
    this.onDelete,
  });

  // Function to make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch $phoneUri');
    }
  }

  // Function to copy text to clipboard
  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    // Note: We can't show SnackBar here since this is a StatelessWidget
    // The feedback will be handled by the parent widget if needed
  }

  // Navigate to tabbed details screen
  void _navigateToDetailsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickupDetailsTabbedScreen(pickup: pickup),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Pickup'),
          content: Text('Are you sure you want to delete pickup #${pickup.pickupNumber}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePickup(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Delete pickup
  Future<void> _deletePickup(BuildContext context) async {
    if (onDelete != null) {
      onDelete!();
    } else {
      // Fallback if no callback is provided
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delete functionality not available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on status
    final bool isPickedUp = pickup.status == 'Picked Up';
    final Color statusColor = isPickedUp ? Colors.green : const Color(0xFFF89C29);
    final String formattedDate = DateFormat('EEE, MMM d, y').format(pickup.pickupDate);
    
    // Responsive values
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context);

    return GestureDetector(
      onTap: () => _navigateToDetailsScreen(context),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: spacing,
          vertical: spacing * 0.67,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pickup ',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 18,
                        tablet: 20,
                        desktop: 22,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2F2F2F),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing * 0.83,
                      vertical: spacing * 0.42,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(borderRadius * 0.5),
                    ),
                    child: Text(
                      pickup.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 13,
                          tablet: 15,
                          desktop: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing * 0.33),
              Row(
                children: [
                  Text(
                    'Pickup #${pickup.pickupNumber}',
                    style: TextStyle(
                      color: const Color(0xff2F2F2F),
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _copyToClipboard('#${pickup.pickupNumber}'),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.copy,
                        color: const Color(0xFFFF6B35),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: Colors.grey,
                    size: iconSize,
                  ),
                  SizedBox(width: spacing * 0.67),
                  Expanded(
                    child: Text(
                      'Contact: ${pickup.contactNumber}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                        color: const Color(0xff2F2F2F),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: spacing * 3,
                    height: spacing * 3,
                    child: ElevatedButton(
                      onPressed: () => _makePhoneCall(pickup.contactNumber),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xff2F2F2F),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.phone,
                          color: const Color(0xff2F2F2F),
                          size: iconSize * 0.9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing * 0.67),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                    size: iconSize,
                  ),
                  SizedBox(width: spacing * 0.67),
                  Expanded(
                    child: Text(
                      pickup.address,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                        color: const Color(0xff2F2F2F),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (pickup.isFragileItem || pickup.isLargeItem)
                         Expanded(
                           child: Wrap(
                             spacing: spacing * 0.67,
                             children: [
                               if (pickup.isFragileItem)
                                 _buildTag('Fragile', Colors.red, context),
                               if (pickup.isLargeItem)
                                 _buildTag('Large Item', Colors.blue, context),
                             ],
                           ),
                         ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing * 0.67,
                            vertical: spacing * 0.33,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(borderRadius * 0.5),
                          ),
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              color: const Color(0xff2F2F2F),
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 12,
                                tablet: 14,
                                desktop: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete button in the same row as date
                  GestureDetector(
                    onTap: () => _showDeleteConfirmation(context),
                    child: Container(
                      padding: EdgeInsets.all(spacing * 0.5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(borderRadius * 0.5),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTag(String text, Color color, BuildContext context) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing * 0.67,
        vertical: spacing * 0.33,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius * 0.5),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}