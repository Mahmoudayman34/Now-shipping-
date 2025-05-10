import 'package:flutter/material.dart';

class StatisticsGrid extends StatelessWidget {
  final int headingToCustomer;
  final int awaitingAction;
  final int successfulOrders;
  final int unsuccessfulOrders;
  final int headingToYou;
  final int newOrders;
  final double successRate;
  final double unsuccessRate;
  
  const StatisticsGrid({
    Key? key,
    required this.headingToCustomer,
    required this.awaitingAction,
    required this.successfulOrders,
    required this.unsuccessfulOrders, 
    required this.headingToYou,
    required this.newOrders,
    this.successRate = 0.0,
    this.unsuccessRate = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5, // Make cards more rectangular and less square
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStatCard("Heading To Customer", headingToCustomer.toString(), Icons.info_outline),
          _buildStatCard("Awaiting Action", awaitingAction.toString(), Icons.info_outline, valueColor: Colors.orange),
          _buildStatCard("Successful Orders", successfulOrders.toString(), Icons.info_outline, 
              showPercentage: true, percentage: successRate),
          _buildStatCard("Unsuccessful Orders", unsuccessfulOrders.toString(), Icons.info_outline, 
              showPercentage: true, percentage: unsuccessRate),
          _buildStatCard("Heading To You", headingToYou.toString(), Icons.info_outline),
          _buildStatCard("New Orders", newOrders.toString(), Icons.info_outline, valueColor: Colors.black),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, 
      {bool showPercentage = false, Color? valueColor, double percentage = 0.0}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: valueColor,
                ),
              ),
              if (showPercentage) ...[
                const SizedBox(width: 4),
                Text(
                  "${percentage.toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}