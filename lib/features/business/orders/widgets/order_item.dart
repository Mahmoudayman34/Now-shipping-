import 'package:flutter/material.dart';
import 'package:now_shipping/core/utils/status_colors.dart';
import 'package:now_shipping/features/business/orders/widgets/order_actions_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderItem extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String location;
  final String amount;
  final String status;
  final String orderType;
  final int attempts;
  final String phoneNumber;
  final VoidCallback onTap;

  const OrderItem({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.location,
    required this.amount,
    required this.status,
    required this.orderType,
    required this.attempts,
    required this.phoneNumber,
    required this.onTap,
  });

  // Function to make a phone call
  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch $phoneUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  Row(
                    children: [
                      Text(
                        '$orderType ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2F2F2F),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('$attempts/2', style: const TextStyle(color: Color(0xff2F2F2F))),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: StatusColors.getBackgroundColor(status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: StatusColors.getTextColor(status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Order #$orderId',
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
                      customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xff2F2F2F),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _makePhoneCall,
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
                      location,
                      style: const TextStyle(
                        fontSize: 16,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'EGP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          amount,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff2F2F2F),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Cash on delivery',
                            style: TextStyle(
                              color: Color(0xff2F2F2F),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Color(0xff2F2F2F)),
                    onPressed: () {
                      showOrderActionsBottomSheet(context, {
                        'orderId': orderId,
                        'customerName': customerName,
                        'location': location,
                        'amount': amount,
                        'status': status,
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}