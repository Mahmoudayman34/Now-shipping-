import 'package:flutter/material.dart';

class NewOrdersNotification extends StatelessWidget {
  final int newOrdersCount;
  
  const NewOrdersNotification({
    Key? key,
    required this.newOrdersCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
               Image.asset('assets/icons/pickup.png', width: 26, height: 26, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  "You have created ",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "$newOrdersCount new ${newOrdersCount == 1 ? 'Order' : 'Orders'}",
                  style: const TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.bold),
                ),
                const Text(".", style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
                child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.teal),
                  padding: const EdgeInsets.all(4),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text('Prepare orders', style: TextStyle(color: Colors.teal)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}