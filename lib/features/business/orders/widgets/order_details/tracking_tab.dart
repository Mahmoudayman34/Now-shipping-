import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:now_shipping/core/utils/status_colors.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/tracking_step_item.dart';

/// The tracking tab showing order tracking timeline
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
    // Get tracking steps based on orderStages data
    final trackingSteps = ref.watch(orderStagesTrackingProvider(orderId));
    
    // If we don't have any tracking steps from orderStages, fall back to the status-based steps
    final steps = trackingSteps.isEmpty 
        ? ref.watch(trackingStepsProvider(status))
        : trackingSteps;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
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
    );
  }
}