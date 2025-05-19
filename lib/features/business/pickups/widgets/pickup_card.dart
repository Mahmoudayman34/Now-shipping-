import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pickup_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/pickup_details_tabbed_screen.dart';

class PickupCard extends StatelessWidget {
  final PickupModel pickup;
  final VoidCallback? onTap;

  const PickupCard({
    super.key,
    required this.pickup,
    this.onTap,
  });

  // Function to make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch $phoneUri');
    }
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

  @override
  Widget build(BuildContext context) {
    // Define colors based on status
    final bool isPickedUp = pickup.status == 'Picked Up';
    final Color statusColor = isPickedUp ? Colors.green : const Color(0xFFF89C29);
    final String formattedDate = DateFormat('EEE, MMM d, y').format(pickup.pickupDate);

    return GestureDetector(
      onTap: () => _navigateToDetailsScreen(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pickup ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2F2F2F),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      pickup.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Pickup #${pickup.pickupId}',
                style: const TextStyle(
                  color: Color(0xff2F2F2F),
                  fontSize: 14,
                ),
              ),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Contact: ${pickup.contactNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff2F2F2F),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _makePhoneCall(pickup.contactNumber),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xff2F2F2F),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.phone, color: Color(0xff2F2F2F), size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pickup.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff2F2F2F),
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
                             spacing: 8,
                             children: [
                               if (pickup.isFragileItem)
                                 _buildTag('Fragile', Colors.red),
                               if (pickup.isLargeItem)
                                 _buildTag('Large Item', Colors.blue),
                             ],
                           ),
                         ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formattedDate, 
                                style: const TextStyle(color: Color(0xff2F2F2F), fontSize: 12)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.more_horiz, color: Color(0xff2F2F2F)),
                  //   onPressed: () {
                  //     // Action for more options
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}