import 'package:flutter/material.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/section_utilities.dart';

/// Action Required section for orders with waitingAction status
class ActionRequiredSection extends StatelessWidget {
  final String orderId;
  final VoidCallback onRetryTomorrow;
  final VoidCallback onScheduleRetry;
  final VoidCallback onReturnToWarehouse;

  const ActionRequiredSection({
    super.key,
    required this.orderId,
    required this.onRetryTomorrow,
    required this.onScheduleRetry,
    required this.onReturnToWarehouse,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Action Required!',
            icon: Icons.error_outline_rounded,
          ),
          const SizedBox(height: 16),
          
          // Warning message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFF6B35).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: const Color(0xFFFF6B35),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This order requires your action. Please choose one of the options below.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Action buttons
          _buildActionButton(
            context,
            icon: Icons.calendar_today_rounded,
            title: 'Retry Tomorrow',
            subtitle: 'Automatically retry delivery tomorrow',
            color: const Color(0xFFFF6B35),
            onTap: onRetryTomorrow,
          ),
          const SizedBox(height: 12),
          
          _buildActionButton(
            context,
            icon: Icons.schedule_rounded,
            title: 'Schedule Retry',
            subtitle: 'Choose a specific date and time',
            color: const Color(0xFF3498DB),
            onTap: onScheduleRetry,
          ),
          const SizedBox(height: 12),
          
          _buildActionButton(
            context,
            icon: Icons.warehouse_rounded,
            title: 'Return to Warehouse',
            subtitle: 'Send the order back to warehouse',
            color: const Color(0xFFE74C3C),
            onTap: onReturnToWarehouse,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

