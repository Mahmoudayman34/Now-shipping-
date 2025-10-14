import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:now_shipping/core/utils/status_colors.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/tracking_step_item.dart';
import '../../../../../core/l10n/app_localizations.dart';

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
    
    // Localize the steps
    final localizedSteps = _localizeTrackingSteps(context, steps);
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
    );
  }

  List<Map<String, dynamic>> _localizeTrackingSteps(BuildContext context, List<Map<String, dynamic>> steps) {
    final l10n = AppLocalizations.of(context);
    
    return steps.map((step) {
      final Map<String, dynamic> localizedStep = Map.from(step);
      
      // Localize based on the title or status
      switch (step['title']?.toString() ?? '') {
        case 'New':
          localizedStep['title'] = l10n.newStatus;
          localizedStep['description'] = l10n.orderCreatedSuccess;
          break;
        case 'Picked up':
          localizedStep['title'] = l10n.pickedUpTitle;
          localizedStep['description'] = l10n.pickedUpDescription;
          break;
        case 'In Stock':
          localizedStep['title'] = l10n.inStockTitle;
          localizedStep['description'] = l10n.inStockDescription;
          break;
        case 'Heading to customer':
          localizedStep['title'] = l10n.headingToCustomerTitle;
          localizedStep['description'] = l10n.headingToCustomerDescription;
          break;
        case 'Successful':
          localizedStep['title'] = l10n.successfulTitle;
          localizedStep['description'] = l10n.successfulDescription;
          break;
      }
      
      return localizedStep;
    }).toList();
  }
}