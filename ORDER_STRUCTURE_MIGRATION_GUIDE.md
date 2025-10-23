# Order Structure Migration Guide

This document outlines the changes made to update the order structure across the entire app to match the new backend schema defined in `mds/order_new_structure.md`.

## Overview

The order system has been updated to support a comprehensive status and stage tracking system with the following improvements:

1. **Status Categories**: Orders are now categorized into 5 high-level categories
2. **Extended Status Set**: Support for 24+ different order statuses
3. **Detailed Stage Tracking**: Separate tracking for delivery and return flows
4. **Courier History**: Complete tracking of courier actions
5. **Status History**: Full audit trail of status changes

## Files Created

### 1. Core Constants (`lib/core/constants/order_constants.dart`)
**Purpose**: Central definition of all order statuses, categories, and stage names

**Key Classes**:
- `OrderStatusCategory` - Enum for 5 status categories (NEW, PROCESSING, PAUSED, SUCCESSFUL, UNSUCCESSFUL)
- `OrderStatus` - All 24+ order status constants with helper methods
- `OrderDeliveryStage` - Constants for main delivery flow stages
- `OrderReturnStage` - Constants for return flow stages
- `CourierAction` - Constants for courier action types

**Usage Example**:
```dart
import 'package:now_shipping/core/constants/order_constants.dart';

// Get category for a status
final category = OrderStatus.getCategory('pickedUp'); // Returns OrderStatusCategory.processing

// Get display name
final displayName = OrderStatus.getDisplayName('headingToCustomer'); // Returns "Heading to Customer"

// Get description
final desc = OrderStatus.getDescription('inProgress'); // Returns full description
```

### 2. Order Stage Models (`lib/features/business/orders/models/order_stage_model.dart`)
**Purpose**: Comprehensive models for all order stages with type-safe fields

**Key Classes**:
- `OrderStageInfo` - Base stage class with common fields (isCompleted, completedAt, notes)
- `DeliveryStageInfo` - Standard delivery stage
- `ReturnInitiatedStageInfo` - Return initiation with initiatedBy and reason
- `ReturnAssignedStageInfo` - Courier assignment details
- `ReturnPickedUpStageInfo` - Pickup details with photos
- `ReturnAtWarehouseStageInfo` - Warehouse receipt with condition notes
- `ReturnInspectionStageInfo` - Inspection results with photos
- `ReturnProcessingStageInfo` - Processing type (refund/exchange/repair)
- `ReturnToBusinessStageInfo` - Return delivery to business
- `ReturnCompletedStageInfo` - Final return completion with signature
- `OrderStages` - Container for all stage types
- `CourierHistoryEntry` - Courier action tracking
- `OrderStatusHistoryEntry` - Status change tracking

**Usage Example**:
```dart
import 'package:now_shipping/features/business/orders/models/order_stage_model.dart';

// Parse order stages from API
final stages = OrderStages.fromJson(apiResponse['orderStages']);

// Check if a stage is completed
if (stages.orderPlaced?.isCompleted == true) {
  final completedAt = stages.orderPlaced?.completedAt;
  // ...
}

// Access return-specific fields
if (stages.returnInitiated != null) {
  final reason = stages.returnInitiated?.reason;
  final initiator = stages.returnInitiated?.initiatedBy;
}
```

### 3. API Order Model (`lib/features/business/orders/models/order_api_model.dart`)
**Purpose**: Comprehensive model matching the new backend structure

**Key Features**:
- Full order status and category tracking
- Integrated `OrderStages` support
- Courier history tracking
- Status history with categories
- Helper getters for common checks

**Usage Example**:
```dart
import 'package:now_shipping/features/business/orders/models/order_api_model.dart';

// Parse from API
final order = ApiOrderModel.fromJson(apiData);

// Use helper getters
if (order.isProcessing) {
  print('Order status: ${order.displayStatus}');
  print('Description: ${order.statusDescription}');
}

// Check order type
if (order.isReturnOrder) {
  // Handle return flow
}

// Access stages
final stages = order.orderStages;
if (stages.delivered?.isCompleted == true) {
  // Order delivered
}
```

### 4. Status Colors Utility (`lib/core/utils/status_colors.dart`)
**Purpose**: Updated color scheme for all new statuses

**New Features**:
- Colors for all 24+ statuses
- Category-based fallback colors
- Methods that handle both display names and API status strings

**Usage Example**:
```dart
import 'package:now_shipping/core/utils/status_colors.dart';

// Get colors by status display name
final bgColor = StatusColors.getBackgroundColor('Pending Pickup');
final textColor = StatusColors.getTextColor('Pending Pickup');

// Get colors from API status (handles normalization)
final bgColor2 = StatusColors.getBackgroundColorFromStatus('pendingPickup');
final textColor2 = StatusColors.getTextColorFromStatus('pendingPickup');

// Get colors by category
final catBgColor = StatusColors.getCategoryBackgroundColor(OrderStatusCategory.processing);
```

### 5. Order Status Helper (`lib/core/utils/order_status_helper.dart`)
**Purpose**: Centralized helper for status localization and utilities

**Key Methods**:
- `getLocalizedStatus()` - Get localized status string
- `getCategoryDisplayName()` - Get category display name
- `getAvailableStatusTabs()` - Get all filterable statuses
- `getStatusTabsByCategory()` - Get statuses grouped by category
- `isReturnStatus()` - Check if status is return-related
- `getStatusIcon()` - Get icon for status category
- `getLocalizedOrderType()` - Get localized order type

**Usage Example**:
```dart
import 'package:now_shipping/core/utils/order_status_helper.dart';

// In a widget
final localizedStatus = OrderStatusHelper.getLocalizedStatus(context, 'returnInitiated');

// Check if return
if (OrderStatusHelper.isReturnStatus(status)) {
  // Handle return UI
}

// Get icon
final icon = OrderStatusHelper.getStatusIcon('inProgress');
```

## Files Updated

### 1. Order Service (`lib/features/business/orders/services/order_service.dart`)
**Changes**:
- Updated `_mapOrderStatus()` to handle all new statuses
- Added mapping for return-related statuses
- Normalized status comparison (removes spaces, lowercase)

### 2. Order Providers (`lib/features/business/orders/providers/orders_provider.dart`)
**Changes**:
- Added `ordersByCategoryProvider` - Filter orders by category
- Added `orderCountsByCategoryProvider` - Get counts by category
- Added `ordersByStatusProvider` - Filter by specific status with normalization
- Import `order_constants.dart` for category enum

### 3. Order Details Provider (`lib/features/business/orders/providers/order_details_provider.dart`)
**Changes**:
- Updated `trackingStepsProvider` to use new statuses
- Added `_isStatusCompletedOrAfter()` helper for better tracking logic
- Normalized status comparisons

### 4. Order Item Widget (`lib/features/business/orders/widgets/order_item.dart`)
**Changes**:
- Use `OrderStatusHelper` for localization instead of local method
- Use `StatusColors.getTextColorFromStatus()` for better color handling
- Removed duplicate localization code

### 5. Additional Details Section (`lib/features/business/orders/widgets/order_details/additional_details_section.dart`)
**Changes**:
- Use `OrderStatusHelper.getLocalizedStatus()`
- Use `StatusColors.getTextColorFromStatus()`
- Removed local `_getLocalizedStatus()` method

## New Status Categories

### NEW (Blue)
- `new` - Order created by business
- `pendingPickup` - Waiting for courier pickup

### PROCESSING (Yellow/Cyan/Gray)
- `pickedUp` - Picked up from business
- `inStock` - Arrived at warehouse
- `inReturnStock` - Returned item received in warehouse
- `inProgress` - Being processed or prepared for delivery
- `headingToCustomer` - Courier heading to customer
- `returnToWarehouse` - Return heading to warehouse
- `headingToYou` - Return heading to business
- `rescheduled` - Delivery rescheduled
- `returnInitiated` - Return process started
- `returnAssigned` - Courier assigned for return
- `returnPickedUp` - Return picked up from customer
- `returnAtWarehouse` - Return at warehouse
- `returnToBusiness` - Return heading to business
- `returnLinked` - Return linked to original order

### PAUSED (Cyan/Red)
- `waitingAction` - Awaiting business action
- `rejected` - Rejected by courier

### SUCCESSFUL (Green)
- `completed` - Delivered to customer
- `returnCompleted` - Return completed successfully

### UNSUCCESSFUL (Red)
- `canceled` - Canceled by business/admin
- `returned` - Returned to business
- `terminated` - Terminated manually
- `deliveryFailed` - Delivery failed
- `autoReturnInitiated` - Auto-triggered return

## Order Stages Structure

### Delivery Flow Stages
1. `orderPlaced` - Order created
2. `packed` - Business packed the order
3. `shipping` - In shipping process
4. `inProgress` - Warehouse processing
5. `outForDelivery` - Courier heading to customer
6. `delivered` - Successfully delivered

### Return Flow Stages
1. `returnInitiated` - Return initiated (with initiatedBy, reason)
2. `returnAssigned` - Courier assigned (with assignedCourier, assignedBy)
3. `returnPickedUp` - Picked up from customer (with pickedUpBy, pickupLocation, pickupPhotos)
4. `returnAtWarehouse` - At warehouse (with receivedBy, warehouseLocation, conditionNotes)
5. `returnInspection` - Inspected (with inspectedBy, inspectionResult, inspectionPhotos)
6. `returnProcessing` - Processing (with processedBy, processingType)
7. `returnToBusiness` - Delivering to business (with assignedCourier, assignedBy)
8. `returnCompleted` - Delivered to business (with completedBy, businessSignature, deliveryLocation)
9. `returned` - Final state (with returnOrderCompleted, returnOrderCompletedAt)

## Migration Checklist

### Backend Integration
- ✅ Order status constants defined
- ✅ Status categories implemented
- ✅ Order stages models created
- ✅ Courier history model created
- ✅ Status history model created

### Data Layer
- ✅ Order repository updated
- ✅ Order service status mapping updated
- ✅ API order model created

### State Management
- ✅ Order providers updated with category filtering
- ✅ Order details provider updated
- ✅ Status counts by category provider added

### UI Layer
- ✅ Status colors updated for all statuses
- ✅ Order item widget updated
- ✅ Order details widget updated
- ✅ Status helper utility created
- ✅ Localization helper added

### Return Flow
- ✅ Return stages models created
- ✅ Return status tracking integrated
- ✅ Return-specific fields supported

## Usage in New Code

### Checking Order Status Category
```dart
import 'package:now_shipping/core/constants/order_constants.dart';

final category = OrderStatus.getCategory(order.status);

switch (category) {
  case OrderStatusCategory.newOrder:
    // Handle new orders
    break;
  case OrderStatusCategory.processing:
    // Handle processing orders
    break;
  case OrderStatusCategory.successful:
    // Show success state
    break;
  // ... other cases
}
```

### Filtering Orders by Category
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/orders_provider.dart';
import 'package:now_shipping/core/constants/order_constants.dart';

class OrdersScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get processing orders only
    final processingOrders = ref.watch(
      ordersByCategoryProvider(OrderStatusCategory.processing)
    );
    
    // Get counts by category
    final counts = ref.watch(orderCountsByCategoryProvider);
    final newOrderCount = counts[OrderStatusCategory.newOrder] ?? 0;
    
    return // ... build UI
  }
}
```

### Displaying Order Stages
```dart
if (order.orderStages.returnInitiated?.isCompleted == true) {
  final returnInfo = order.orderStages.returnInitiated!;
  
  Text('Return initiated by: ${returnInfo.initiatedBy}');
  Text('Reason: ${returnInfo.reason}');
  Text('Date: ${returnInfo.completedAt}');
}
```

### Getting Localized Status
```dart
import 'package:now_shipping/core/utils/order_status_helper.dart';

// In a widget
Text(
  OrderStatusHelper.getLocalizedStatus(context, order.status),
  style: TextStyle(
    color: StatusColors.getTextColorFromStatus(order.status),
  ),
);
```

## Backward Compatibility

The new structure maintains backward compatibility with existing code:

1. **Status mapping**: Old statuses are automatically mapped to new ones
2. **Color fallback**: Unknown statuses fall back to category colors
3. **Legacy providers**: Old providers still work alongside new ones
4. **API compatibility**: Both old and new API response formats are supported

## Testing Recommendations

1. **Status Categories**: Verify all statuses map to correct categories
2. **Color Rendering**: Check all status colors display correctly
3. **Filtering**: Test category-based and status-based filtering
4. **Return Flow**: Test complete return order lifecycle
5. **Localization**: Verify all statuses have proper translations
6. **Stage Tracking**: Test order stage progression
7. **Backward Compatibility**: Ensure existing features still work

## Next Steps

1. **Add Localization**: Add translations for new statuses in `.arb` files
2. **Update Documentation**: Document return flow for users
3. **API Synchronization**: Ensure backend sends data in new format
4. **Analytics**: Add tracking for new status categories
5. **Testing**: Comprehensive testing of all status flows

## Support

For questions or issues related to this migration:
- Refer to `mds/order_new_structure.md` for backend structure
- Check `lib/core/constants/order_constants.dart` for status definitions
- See usage examples in this document

