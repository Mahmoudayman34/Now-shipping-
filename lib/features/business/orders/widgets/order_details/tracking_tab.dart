import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:now_shipping/core/utils/responsive_utils.dart';
import 'package:now_shipping/core/l10n/app_localizations.dart';
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
    // Get raw order data to build localized tracking steps
    final rawOrderData = ref.watch(rawOrderDataProvider(orderId));
    
    // Show loading if no data yet
    if (rawOrderData.isEmpty) {
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
            Text(
              AppLocalizations.of(context).loadingTrackingInformation,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    // Build localized tracking steps
    final localizedSteps = _buildLocalizedTrackingSteps(rawOrderData, context);
    
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

  /// Build localized tracking steps from raw order data
  List<Map<String, dynamic>> _buildLocalizedTrackingSteps(Map<String, dynamic> rawOrderData, BuildContext context) {
    // Get the stageTimeline from API response
    final stageTimeline = rawOrderData['stageTimeline'] as List<dynamic>? ?? [];
    final orderStages = rawOrderData['orderStages'] as Map<String, dynamic>? ?? {};
    final orderType = rawOrderData['orderShipping']?['orderType'] ?? 'Deliver';
    
    // Build tracking steps from ONLY completed stages in the timeline
    final List<Map<String, dynamic>> trackingSteps = [];
    
    for (int i = 0; i < stageTimeline.length; i++) {
      final stage = stageTimeline[i] as Map<String, dynamic>;
      final stageName = stage['stage'] as String;
      final isCompleted = stage['isCompleted'] as bool? ?? false;
      
      // ONLY add stages that are completed
      if (!isCompleted) {
        continue;
      }
      
      final completedAt = stage['completedAt'] as String?;
      
      // Format the completed time
      String formattedTime = '';
      if (completedAt != null && completedAt.isNotEmpty) {
        try {
          final dateTime = DateTime.parse(completedAt);
          formattedTime = DateFormat('dd MMM yyyy - HH:mm').format(dateTime);
        } catch (e) {
          formattedTime = '';
        }
      }
      
      // Get localized display name and description
      final displayName = _getLocalizedStageDisplayName(stageName, context);
      final description = _getLocalizedStageDefaultDescription(stageName, context);
      
      trackingSteps.add({
        'title': displayName,
        'status': stageName,
        'description': description,
        'time': formattedTime,
        'isCompleted': true,
        'isFirst': false,
        'isLast': false,
      });
    }
    
    // If we have a return order, check if we need to add return stages from orderStages
    if (orderType == 'Return') {
      // Check for return stages that are completed but not in timeline
      final returnStageKeys = [
        'returnInitiated',
        'returnAssigned',
        'returnPickedUp',
        'returnAtWarehouse',
        'returnInspection',
        'returnProcessing',
        'returnToBusiness',
        'returnCompleted',
      ];
      
      for (final stageKey in returnStageKeys) {
        final stageData = orderStages[stageKey] as Map<String, dynamic>?;
        if (stageData != null && stageData['isCompleted'] == true) {
          // Check if already in timeline
          final alreadyInTimeline = trackingSteps.any((step) => step['status'] == stageKey);
          if (!alreadyInTimeline) {
            final completedAt = stageData['completedAt'] as String?;
            String formattedTime = '';
            if (completedAt != null && completedAt.isNotEmpty) {
              try {
                final dateTime = DateTime.parse(completedAt);
                formattedTime = DateFormat('dd MMM yyyy - HH:mm').format(dateTime);
              } catch (e) {
                formattedTime = '';
              }
            }
            
            trackingSteps.add({
              'title': _getLocalizedStageDisplayName(stageKey, context),
              'status': stageKey,
              'description': _getLocalizedStageDefaultDescription(stageKey, context),
              'time': formattedTime,
              'isCompleted': true,
              'isFirst': false,
              'isLast': false,
            });
          }
        }
      }
    }
    
    // Mark first and last items
    if (trackingSteps.isNotEmpty) {
      trackingSteps.first['isFirst'] = true;
      trackingSteps.last['isLast'] = true;
    }
    
    return trackingSteps;
  }

  /// Get localized display name for stage
  String _getLocalizedStageDisplayName(String stageName, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    switch (stageName) {
      case 'orderPlaced':
        return l10n.orderPlaced;
      case 'packed':
        return l10n.packed;
      case 'shipping':
        return l10n.shipping;
      case 'inProgress':
        return l10n.inProgress;
      case 'outForDelivery':
        return l10n.outForDelivery;
      case 'delivered':
        return l10n.delivered;
      case 'returnInitiated':
        return l10n.returnInitiated;
      case 'returnAssigned':
        return l10n.returnAssigned;
      case 'returnPickedUp':
        return l10n.returnPickedUp;
      case 'returnAtWarehouse':
        return l10n.returnAtWarehouse;
      case 'returnInspection':
        return l10n.returnInspection;
      case 'returnProcessing':
        return l10n.returnProcessing;
      case 'returnToBusiness':
        return l10n.returnToBusiness;
      case 'returnCompleted':
        return l10n.returnCompleted;
      case 'returned':
        return l10n.returnedStatus;
      default:
        return stageName;
    }
  }

  /// Get localized default description for stage
  String _getLocalizedStageDefaultDescription(String stageName, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    switch (stageName) {
      case 'orderPlaced':
        return l10n.orderHasBeenCreated;
      case 'packed':
        return l10n.fastShippingMarkedCompleted;
      case 'shipping':
        return l10n.fastShippingMarkedCompleted;
      case 'inProgress':
        return l10n.fastShippingAssignedToCourier;
      case 'outForDelivery':
        return l10n.fastShippingReadyForDelivery;
      case 'delivered':
        return l10n.orderCompletedByCourier;
      case 'returnInitiated':
        return l10n.returnInitiated;
      case 'returnAssigned':
        return l10n.returnAssigned;
      case 'returnPickedUp':
        return l10n.returnPickedUp;
      case 'returnAtWarehouse':
        return l10n.returnAtWarehouse;
      case 'returnInspection':
        return l10n.returnInspection;
      case 'returnProcessing':
        return l10n.returnProcessing;
      case 'returnToBusiness':
        return l10n.returnToBusiness;
      case 'returnCompleted':
        return l10n.returnCompleted;
      case 'returned':
        return l10n.returnedStatus;
      default:
        return '';
    }
  }

}