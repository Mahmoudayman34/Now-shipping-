/// Order Status and Stage Constants
/// Based on the new order structure defined in mds/order_new_structure.md
library;

/// Status Categories - High level classification of order states
enum OrderStatusCategory {
  newOrder('NEW'),
  processing('PROCESSING'),
  paused('PAUSED'),
  successful('SUCCESSFUL'),
  unsuccessful('UNSUCCESSFUL');

  final String value;
  const OrderStatusCategory(this.value);

  @override
  String toString() => value;
}

/// All supported order statuses
class OrderStatus {
  // NEW Category
  static const String newOrder = 'new';
  static const String pendingPickup = 'pendingPickup';
  
  // PROCESSING Category
  static const String pickedUp = 'pickedUp';
  static const String inStock = 'inStock';
  static const String inReturnStock = 'inReturnStock';
  static const String inProgress = 'inProgress';
  static const String headingToCustomer = 'headingToCustomer';
  static const String returnToWarehouse = 'returnToWarehouse';
  static const String headingToYou = 'headingToYou';
  static const String rescheduled = 'rescheduled';
  static const String returnInitiated = 'returnInitiated';
  static const String returnAssigned = 'returnAssigned';
  static const String returnPickedUp = 'returnPickedUp';
  static const String returnAtWarehouse = 'returnAtWarehouse';
  static const String returnToBusiness = 'returnToBusiness';
  static const String returnLinked = 'returnLinked';
  
  // PAUSED Category
  static const String waitingAction = 'waitingAction';
  static const String rejected = 'rejected';
  
  // SUCCESSFUL Category
  static const String completed = 'completed';
  static const String returnCompleted = 'returnCompleted';
  
  // UNSUCCESSFUL Category
  static const String canceled = 'canceled';
  static const String returned = 'returned';
  static const String terminated = 'terminated';
  static const String deliveryFailed = 'deliveryFailed';
  static const String autoReturnInitiated = 'autoReturnInitiated';

  /// Get the category for a given status
  static OrderStatusCategory getCategory(String status) {
    // Normalize the status by removing spaces and converting to lowercase
    final normalizedStatus = status.toLowerCase().replaceAll(' ', '');
    
    switch (normalizedStatus) {
      // NEW
      case 'new':
      case 'pendingpickup':
        return OrderStatusCategory.newOrder;
      
      // PROCESSING
      case 'pickedup':
      case 'instock':
      case 'inreturnstock':
      case 'inprogress':
      case 'headingtocustomer':
      case 'returntowarehouse':
      case 'headingtoyou':
      case 'rescheduled':
      case 'returninitiated':
      case 'returnassigned':
      case 'returnpickedup':
      case 'returnatwarehouse':
      case 'returntobusiness':
      case 'returnlinked':
        return OrderStatusCategory.processing;
      
      // PAUSED
      case 'waitingaction':
      case 'rejected':
        return OrderStatusCategory.paused;
      
      // SUCCESSFUL
      case 'completed':
      case 'returncompleted':
        return OrderStatusCategory.successful;
      
      // UNSUCCESSFUL
      case 'canceled':
      case 'cancelled':
      case 'returned':
      case 'terminated':
      case 'deliveryfailed':
      case 'autoreturninitiated':
        return OrderStatusCategory.unsuccessful;
      
      default:
        return OrderStatusCategory.newOrder;
    }
  }

  /// Get display name for status
  static String getDisplayName(String status) {
    final Map<String, String> displayNames = {
      newOrder: 'New',
      pendingPickup: 'Pending Pickup',
      pickedUp: 'Picked Up',
      inStock: 'In Stock',
      inReturnStock: 'In Return Stock',
      inProgress: 'In Progress',
      headingToCustomer: 'Heading to Customer',
      returnToWarehouse: 'Return to Warehouse',
      headingToYou: 'Heading to You',
      rescheduled: 'Rescheduled',
      waitingAction: 'Waiting Action',
      rejected: 'Rejected',
      completed: 'Completed',
      returnCompleted: 'Return Completed',
      canceled: 'Canceled',
      returned: 'Returned',
      terminated: 'Terminated',
      deliveryFailed: 'Delivery Failed',
      autoReturnInitiated: 'Auto Return Initiated',
      returnInitiated: 'Return Initiated',
      returnAssigned: 'Return Assigned',
      returnPickedUp: 'Return Picked Up',
      returnAtWarehouse: 'Return at Warehouse',
      returnToBusiness: 'Return to Business',
      returnLinked: 'Return Linked',
    };
    
    return displayNames[status.toLowerCase()] ?? status;
  }

  /// Get status description
  static String getDescription(String status) {
    final Map<String, String> descriptions = {
      newOrder: 'Order created by business',
      pendingPickup: 'Waiting for courier pickup',
      pickedUp: 'Picked up from business',
      inStock: 'Arrived at warehouse',
      inReturnStock: 'Returned item received in warehouse',
      inProgress: 'Being processed or prepared for delivery',
      headingToCustomer: 'Courier is on the way to deliver to customer',
      returnToWarehouse: 'Return order on the way to warehouse',
      headingToYou: 'Return heading back to business',
      rescheduled: 'Delivery rescheduled',
      waitingAction: 'Awaiting business response or action',
      rejected: 'Order rejected by courier',
      completed: 'Delivered successfully to customer',
      returnCompleted: 'Return successfully completed',
      canceled: 'Canceled by business or admin',
      returned: 'Returned to business',
      terminated: 'Terminated manually by admin',
      deliveryFailed: 'Delivery failed (customer unavailable/rejected)',
      autoReturnInitiated: 'System auto-triggered a return flow',
      returnInitiated: 'Business initiated a return process',
      returnAssigned: 'Courier assigned for return pickup',
      returnPickedUp: 'Return picked up from customer',
      returnAtWarehouse: 'Returned item received at warehouse',
      returnToBusiness: 'Courier assigned to deliver return to business',
      returnLinked: 'Return order linked to its original delivery order',
    };
    
    return descriptions[status.toLowerCase()] ?? '';
  }
}

/// Main delivery flow stages
class OrderDeliveryStage {
  static const String orderPlaced = 'orderPlaced';
  static const String packed = 'packed';
  static const String shipping = 'shipping';
  static const String inProgress = 'inProgress';
  static const String outForDelivery = 'outForDelivery';
  static const String delivered = 'delivered';

  /// Get display name for delivery stage
  static String getDisplayName(String stage) {
    final Map<String, String> displayNames = {
      orderPlaced: 'Order Placed',
      packed: 'Packed',
      shipping: 'Shipping',
      inProgress: 'In Progress',
      outForDelivery: 'Out for Delivery',
      delivered: 'Delivered',
    };
    
    return displayNames[stage] ?? stage;
  }

  /// Get description for delivery stage
  static String getDescription(String stage) {
    final Map<String, String> descriptions = {
      orderPlaced: 'Order created successfully',
      packed: 'Business packed the order',
      shipping: 'Order in shipping process',
      inProgress: 'Warehouse is processing the order',
      outForDelivery: 'Courier heading to customer',
      delivered: 'Delivered successfully',
    };
    
    return descriptions[stage] ?? '';
  }
}

/// Return flow stages
class OrderReturnStage {
  static const String returnInitiated = 'returnInitiated';
  static const String returnAssigned = 'returnAssigned';
  static const String returnPickedUp = 'returnPickedUp';
  static const String returnAtWarehouse = 'returnAtWarehouse';
  static const String returnInspection = 'returnInspection';
  static const String returnProcessing = 'returnProcessing';
  static const String returnToBusiness = 'returnToBusiness';
  static const String returnCompleted = 'returnCompleted';
  static const String returned = 'returned';

  /// Get display name for return stage
  static String getDisplayName(String stage) {
    final Map<String, String> displayNames = {
      returnInitiated: 'Return Initiated',
      returnAssigned: 'Courier Assigned',
      returnPickedUp: 'Return Picked Up',
      returnAtWarehouse: 'At Warehouse',
      returnInspection: 'Inspection',
      returnProcessing: 'Processing',
      returnToBusiness: 'Returning to Business',
      returnCompleted: 'Return Completed',
      returned: 'Returned',
    };
    
    return displayNames[stage] ?? stage;
  }

  /// Get description for return stage
  static String getDescription(String stage) {
    final Map<String, String> descriptions = {
      returnInitiated: 'Business or system initiates return',
      returnAssigned: 'Admin assigns courier for pickup',
      returnPickedUp: 'Courier picked up from customer',
      returnAtWarehouse: 'Return item received at warehouse',
      returnInspection: 'Inspection at warehouse',
      returnProcessing: 'Refund/Exchange/Repair processing',
      returnToBusiness: 'Courier assigned to deliver return to business',
      returnCompleted: 'Return successfully delivered to business',
      returned: 'Final state confirming return completion',
    };
    
    return descriptions[stage] ?? '';
  }
}

/// Courier action types
class CourierAction {
  static const String assigned = 'assigned';
  static const String pickupFromCustomer = 'pickup_from_customer';
  static const String deliveredToWarehouse = 'delivered_to_warehouse';
  static const String pickupFromWarehouse = 'pickup_from_warehouse';
  static const String deliveredToBusiness = 'delivered_to_business';
  static const String completed = 'completed';

  /// Get display name for courier action
  static String getDisplayName(String action) {
    final Map<String, String> displayNames = {
      assigned: 'Assigned',
      pickupFromCustomer: 'Pickup from Customer',
      deliveredToWarehouse: 'Delivered to Warehouse',
      pickupFromWarehouse: 'Pickup from Warehouse',
      deliveredToBusiness: 'Delivered to Business',
      completed: 'Completed',
    };
    
    return displayNames[action] ?? action;
  }
}

