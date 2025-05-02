import 'package:flutter/material.dart';

class CashSummary extends StatelessWidget {
  final double expectedCash;
  final double collectedCash;
  final double collectionRate;
  
  const CashSummary({
    Key? key,
    required this.expectedCash,
    required this.collectedCash,
    this.collectionRate = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildCashItem("Expected Cash", "${expectedCash.toStringAsFixed(1)} EGP"),
            _buildCashItem("Collected Cash", "${collectedCash.toStringAsFixed(1)} EGP", 
              valueColor: Colors.green, showPercentage: true),
          ],
        ),
      ),
    );
  }

  Widget _buildCashItem(String label, String value, {Color? valueColor, bool showPercentage = false}) {
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
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: valueColor,
                ),
              ),
              if (showPercentage) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${collectionRate.toStringAsFixed(0)} %",
                    style: TextStyle(
                      color: valueColor ?? Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}