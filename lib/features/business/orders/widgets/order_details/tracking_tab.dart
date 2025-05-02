import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:tes1/core/utils/status_colors.dart';
import 'package:tes1/features/business/orders/providers/order_details_provider.dart';
import 'package:tes1/features/business/orders/widgets/order_details/tracking_step_item.dart';

/// The tracking tab showing order tracking timeline
class TrackingTab extends ConsumerWidget {
  final String status;

  const TrackingTab({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get tracking steps based on current order status
    final trackingSteps = ref.watch(trackingStepsProvider(status));
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      itemCount: trackingSteps.length,
      itemBuilder: (context, index) {
        final step = trackingSteps[index];
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