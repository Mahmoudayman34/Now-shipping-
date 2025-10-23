import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/core/utils/responsive_utils.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/tracking_step_item.dart';

/// The tracking tab showing order tracking timeline (Responsive)
class TrackingTab extends ConsumerWidget {
  final String orderId;
  final String status;

  const TrackingTab({
    super.key,
    required this.orderId,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get tracking steps based on dynamic API data (orderStages and stageTimeline)
    final steps = ref.watch(trackingStepsProvider(orderId));
    
    // Show loading if no steps yet
    if (steps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading tracking information...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    // Keep steps as is (descriptions come from API notes)
    final localizedSteps = steps;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView.builder(
        padding: ResponsiveUtils.getResponsivePadding(context),
        itemCount: localizedSteps.length,
        itemBuilder: (context, index) {
          final step = localizedSteps[index];
          return TrackingStepItem(
            isCompleted: step['isCompleted'],
            title: step['title'],
            status: step['status'],
            description: step['description'],
            time: step['time'],
            isFirst: step['isFirst'] ?? false,
            isLast: step['isLast'] ?? false,
          );
        },
      ),
    );
  }

}