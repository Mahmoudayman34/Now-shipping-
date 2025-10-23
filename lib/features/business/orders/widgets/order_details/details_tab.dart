import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/providers/orders_provider.dart' hide orderDetailsProvider;
import 'package:now_shipping/features/business/orders/widgets/order_details/customer_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/shipping_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/delivery_details_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/exchange_details_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/return_details_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/additional_details_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/action_required_section.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/rescheduled_note_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/cancel_order_button.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/scan_sticker_button.dart';

/// The details tab showing customer and order information
class DetailsTab extends ConsumerWidget {
  final String orderId;
  final VoidCallback onScanSticker;

  const DetailsTab({
    super.key,
    required this.orderId,
    required this.onScanSticker,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get order details from the provider
    final orderDetails = ref.watch(orderDetailsProvider(orderId));
    
    if (orderDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Get the actual order _id from raw data
    final rawOrderData = ref.watch(rawOrderDataProvider(orderId));
    final actualOrderId = rawOrderData['_id'] as String? ?? orderId;
    
    // Check if status is waitingAction
    final isWaitingAction = orderDetails.status.toLowerCase().replaceAll(' ', '') == 'waitingaction';
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      children: [
        // Scan Smart Sticker button at the top
        ScanStickerButton(onTap: onScanSticker),
        const SizedBox(height: 16),
        
        // Rescheduled note (if order has been rescheduled)
        if (orderDetails.scheduledRetryAt != null && orderDetails.scheduledRetryAt!.isNotEmpty) ...[
          RescheduledNoteWidget(scheduledRetryAt: orderDetails.scheduledRetryAt!),
        ],
        
        // Action Required section (only for waitingAction status)
        if (isWaitingAction) ...[
          ActionRequiredSection(
            orderId: orderId,
            onRetryTomorrow: () => _handleRetryTomorrow(context, ref, actualOrderId),
            onScheduleRetry: () => _handleScheduleRetry(context, ref, actualOrderId),
            onReturnToWarehouse: () => _handleReturnToWarehouse(context, ref, actualOrderId),
          ),
          const SizedBox(height: 16),
        ],
        
        // Customer section
        CustomerSection(orderDetails: orderDetails),
        const SizedBox(height: 16),
        
        // Shipping section
        ShippingSection(deliveryType: orderDetails.deliveryType),
        const SizedBox(height: 16),
        
        // Show different package details section based on delivery type
        if (orderDetails.deliveryType == 'Deliver')
          DeliveryDetailsSection(orderDetails: orderDetails)
        else if (orderDetails.deliveryType == 'Exchange')
          ExchangeDetailsSection(orderDetails: orderDetails)
        else if (orderDetails.deliveryType == 'Return')
          ReturnDetailsSection(orderDetails: orderDetails),
        
        const SizedBox(height: 16),
        
        // Additional details section
        AdditionalDetailsSection(orderDetails: orderDetails),
        
        // Cancel order button (only for cancellable statuses)
        if (_isOrderCancellable(orderDetails, rawOrderData))
          CancelOrderButton(
            orderId: orderId,
            onCancel: () => _handleCancelOrder(context, ref, actualOrderId),
          ),
      ],
    );
  }
  
  // Check if order can be cancelled based on order stages
  bool _isOrderCancellable(OrderDetailsModel orderDetails, Map<String, dynamic> rawOrderData) {
    final status = orderDetails.status.toLowerCase();
    
    // Get order stages from raw data
    final orderStages = rawOrderData['orderStages'] as Map<String, dynamic>? ?? {};
    
    // Orders can be cancelled if:
    // 1. Status is new, pendingPickup, pickedUp, inStock, inProgress, waitingAction, rejected
    // 2. Order has not been packed yet (packed stage is not completed)
    // 3. Order has not been shipped yet (shipping stage is not completed)
    // 4. Order has not been delivered yet (delivered stage is not completed)
    
    final cancellableStatuses = [
      'new',
      'pendingPickup', 
      'pickedUp',
      'instock',  // Fixed: lowercase to match API response
      'inStock',  // Keep both for compatibility
      'inProgress',
      'waitingAction',
      'rejected',
      'rescheduled',
    ];
    
    // Check if status allows cancellation
    if (!cancellableStatuses.contains(status)) {
      return false;
    }
    
    // Check if order has progressed too far to be cancelled
    final packedStage = orderStages['packed'] as Map<String, dynamic>?;
    final shippingStage = orderStages['shipping'] as Map<String, dynamic>?;
    final deliveredStage = orderStages['delivered'] as Map<String, dynamic>?;
    final outForDeliveryStage = orderStages['outForDelivery'] as Map<String, dynamic>?;
    
    // Special case: "In Stock" and "Rescheduled" orders can be cancelled even if packed/shipped
    // as long as they haven't gone out for delivery
    if (status == 'instock' || status == 'inStock' || status == 'rescheduled') {
      // Cannot cancel if order has gone out for delivery
      if (outForDeliveryStage?['isCompleted'] == true) {
        return false;
      }
      
      // Cannot cancel if order has been delivered
      if (deliveredStage?['isCompleted'] == true) {
        return false;
      }
      
      return true;
    }
    
    // For other statuses, use stricter rules
    // Cannot cancel if order has been packed
    if (packedStage?['isCompleted'] == true) {
      return false;
    }
    
    // Cannot cancel if order has been shipped
    if (shippingStage?['isCompleted'] == true) {
      return false;
    }
    
    // Cannot cancel if order has been delivered
    if (deliveredStage?['isCompleted'] == true) {
      return false;
    }
    
    // For return orders, check return stages
    if (orderDetails.deliveryType == 'Return') {
      final returnInitiated = orderStages['returnInitiated'] as Map<String, dynamic>?;
      final returnAssigned = orderStages['returnAssigned'] as Map<String, dynamic>?;
      final returnPickedUp = orderStages['returnPickedUp'] as Map<String, dynamic>?;
      
      // Cannot cancel if return has been initiated and assigned
      if (returnInitiated?['isCompleted'] == true && returnAssigned?['isCompleted'] == true) {
        return false;
      }
      
      // Cannot cancel if return has been picked up
      if (returnPickedUp?['isCompleted'] == true) {
        return false;
      }
    }
    
    return true;
  }
  
  // Action handlers
  void _handleRetryTomorrow(BuildContext context, WidgetRef ref, String actualOrderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: Color(0xFFFF6B35)),
            SizedBox(width: 12),
            Text('Retry Tomorrow'),
          ],
        ),
        content: Text(
          'Are you sure you want to schedule this order for automatic retry tomorrow?',
          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get the navigator before any async operations
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              // Close confirmation dialog
              navigator.pop();
              
              // Show full-screen loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => PopScope(
                  canPop: false,
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
              
              try {
                // Call API with actual order _id
                final orderService = ref.read(orderServiceProvider);
                print('DEBUG: Using order ID: $actualOrderId');
                final response = await orderService.retryTomorrow(actualOrderId);
                
                // Refresh orders list
                ref.invalidate(ordersProvider);
                
                // Get message from API response
                final message = response['message'] ?? 'Order scheduled for retry tomorrow';
                
                // Close loading dialog
                navigator.pop();
                
                // Navigate back to orders screen
                navigator.pop();
                
                // Show success message
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('✓ $message'),
                    backgroundColor: const Color(0xFF2ECC71),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                // Close loading dialog
                navigator.pop();
                
                // Extract error message
                String errorMessage = 'Failed to schedule retry';
                if (e.toString().contains('Exception:')) {
                  errorMessage = e.toString().replaceAll('Exception:', '').trim();
                }
                
                // Show error message
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleScheduleRetry(BuildContext context, WidgetRef ref, String actualOrderId) async {
    // Show date picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3498DB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate == null) return;
    
    // Show confirmation dialog
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.schedule_rounded, color: Color(0xFF3498DB)),
              SizedBox(width: 12),
              Text('Confirm Schedule'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Schedule retry for:',
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF3498DB).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF3498DB), size: 24),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(pickedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                // Get the navigator before any async operations
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                // Close date picker dialog
                navigator.pop();
                
                // Show full-screen loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (loadingContext) => PopScope(
                    canPop: false,
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Processing...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                
                try {
                  // Call API with actual order _id
                  final orderService = ref.read(orderServiceProvider);
                  print('DEBUG: Using order ID for scheduled retry: $actualOrderId');
                  final response = await orderService.retryScheduled(actualOrderId, pickedDate);
                  
                  // Refresh orders list
                  ref.invalidate(ordersProvider);
                  
                  // Get message from API response
                  final message = response['message'] ?? 'Retry scheduled for ${_formatDate(pickedDate)}';
                  
                  // Close loading dialog
                  navigator.pop();
                  
                  // Navigate back to orders screen
                  navigator.pop();
                  
                  // Show success message
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('✓ $message'),
                      backgroundColor: const Color(0xFF2ECC71),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  // Close loading dialog
                  navigator.pop();
                  
                  // Extract error message
                  String errorMessage = 'Failed to schedule retry';
                  if (e.toString().contains('Exception:')) {
                    errorMessage = e.toString().replaceAll('Exception:', '').trim();
                  }
                  
                  // Show error message
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }
  
  // Helper method to format date
  String _formatDate(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }
  
  void _handleReturnToWarehouse(BuildContext context, WidgetRef ref, String actualOrderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warehouse_rounded, color: Color(0xFFE74C3C)),
            SizedBox(width: 12),
            Text('Return to Warehouse'),
          ],
        ),
        content: Text(
          'Are you sure you want to return this order to the warehouse? This action cannot be undone.',
          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get the navigator before any async operations
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              // Close confirmation dialog
              navigator.pop();
              
              // Show full-screen loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => PopScope(
                  canPop: false,
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE74C3C)),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
              
              try {
                // Call API with actual order _id
                final orderService = ref.read(orderServiceProvider);
                print('DEBUG: Using order ID for return to warehouse: $actualOrderId');
                final response = await orderService.returnToWarehouse(actualOrderId);
                
                // Refresh orders list
                ref.invalidate(ordersProvider);
                
                // Get message from API response
                final message = response['message'] ?? 'Order returned to warehouse';
                
                // Close loading dialog
                navigator.pop();
                
                // Navigate back to orders screen
                navigator.pop();
                
                // Show success message
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('✓ $message'),
                    backgroundColor: const Color(0xFF2ECC71),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                // Close loading dialog
                navigator.pop();
                
                // Extract error message
                String errorMessage = 'Failed to return order to warehouse';
                if (e.toString().contains('Exception:')) {
                  errorMessage = e.toString().replaceAll('Exception:', '').trim();
                }
                
                // Show error message
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm Return'),
          ),
        ],
      ),
    );
  }

  // Cancel order handler
  void _handleCancelOrder(BuildContext context, WidgetRef ref, String actualOrderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFE74C3C), size: 28),
            SizedBox(width: 12),
            Text('Cancel Order'),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Order', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get the navigator before any async operations
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              // Close confirmation dialog
              navigator.pop();
              
              // Show full-screen loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => PopScope(
                  canPop: false,
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE74C3C)),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Cancelling order...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
              
              try {
                // Call API to cancel order
                final orderService = ref.read(orderServiceProvider);
                print('DEBUG: Cancelling order with ID: $actualOrderId');
                final response = await orderService.cancelOrder(actualOrderId);
                
                // Refresh orders list
                ref.invalidate(ordersProvider);
                
                // Get message from API response
                final message = response['message'] ?? 'Order cancelled successfully';
                
                // Close loading dialog
                navigator.pop();
                
                // Navigate back to orders screen
                navigator.pop();
                
                // Show success message
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('✓ $message'),
                    backgroundColor: const Color(0xFF2ECC71),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                // Close loading dialog
                navigator.pop();
                
                // Extract error message
                String errorMessage = 'Failed to cancel order';
                if (e.toString().contains('Exception:')) {
                  errorMessage = e.toString().replaceAll('Exception:', '').trim();
                }
                
                // Show error message
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }
}