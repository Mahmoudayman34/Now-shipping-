import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';

class TodayOverview extends StatelessWidget {
  final int inHubPackages;
  final int toDeliverToday;
  
  const TodayOverview({
    Key? key,
    required this.inHubPackages,
    required this.toDeliverToday,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:  [
              Image.asset('assets/icons/calendar.png', width: 20, height: 20, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                "Today's Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildOverviewItem("You have in our hubs", "$inHubPackages Packages"),
                _buildOverviewItem("Today we should deliver", "$toDeliverToday Packages"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}