/// Models for Order Stages based on the new order structure
library;

class OrderStageInfo {
  final bool isCompleted;
  final DateTime? completedAt;
  final String? notes;

  OrderStageInfo({
    required this.isCompleted,
    this.completedAt,
    this.notes,
  });

  factory OrderStageInfo.fromJson(Map<String, dynamic> json) {
    return OrderStageInfo(
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

/// Delivery flow stage with standard fields
class DeliveryStageInfo extends OrderStageInfo {
  DeliveryStageInfo({
    required super.isCompleted,
    super.completedAt,
    super.notes,
  });

  factory DeliveryStageInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryStageInfo(
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
    );
  }
}

/// Return Initiated stage with additional fields
class ReturnInitiatedStageInfo extends OrderStageInfo {
  final String? initiatedBy;
  final String? reason;

  ReturnInitiatedStageInfo({
    required super.isCompleted,
    super.completedAt,
    super.notes,
    this.initiatedBy,
    this.reason,
  });

  factory ReturnInitiatedStageInfo.fromJson(Map<String, dynamic> json) {
    return ReturnInitiatedStageInfo(
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
      initiatedBy: json['initiatedBy'],
      reason: json['reason'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'initiatedBy': initiatedBy,
      'reason': reason,
    };
  }
}

/// Return Assigned stage with additional fields
class ReturnAssignedStageInfo extends OrderStageInfo {
  final String? assignedCourier;
  final String? assignedBy;

  ReturnAssignedStageInfo({
    required super.isCompleted,
    super.completedAt,
    super.notes,
    this.assignedCourier,
    this.assignedBy,
  });

  factory ReturnAssignedStageInfo.fromJson(Map<String, dynamic> json) {
    return ReturnAssignedStageInfo(
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
      assignedCourier: json['assignedCourier'],
      assignedBy: json['assignedBy'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'assignedCourier': assignedCourier,
      'assignedBy': assignedBy,
    };
  }
}

/// Return Picked Up stage with additional fields
class ReturnPickedUpStageInfo extends OrderStageInfo {
  final String? pickedUpBy;
  final String? pickupLocation;
  final List<String>? pickupPhotos;

  ReturnPickedUpStageInfo({
    required super.isCompleted,
    super.completedAt,
    super.notes,
    this.pickedUpBy,
    this.pickupLocation,
    this.pickupPhotos,
  });

  factory ReturnPickedUpStageInfo.fromJson(Map<String, dynamic> json) {
    return ReturnPickedUpStageInfo(
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
      pickedUpBy: json['pickedUpBy'],
      pickupLocation: json['pickupLocation'],
      pickupPhotos: json['pickupPhotos'] != null 
          ? List<String>.from(json['pickupPhotos'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'pickedUpBy': pickedUpBy,
      'pickupLocation': pickupLocation,
      'pickupPhotos': pickupPhotos,
    };
  }
}

/// Return At Warehouse stage with additional fields
class ReturnAtWarehouseStageInfo extends OrderStageInfo {
  final String? receivedBy;
  final String? warehouseLocation;
  final String? conditionNotes;

  ReturnAtWarehouseStageInfo({
    required super.isCompleted,
    super.completedAt,
    super.notes,
    this.receivedBy,
    this.warehouseLocation,
    this.conditionNotes,
  });

  factory ReturnAtWarehouseStageInfo.fromJson(Map<String, dynamic> json) {
    return ReturnAtWarehouseStageInfo(
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
      receivedBy: json['receivedBy'],
      warehouseLocation: json['warehouseLocation'],
      conditionNotes: json['conditionNotes'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'receivedBy': receivedBy,
      'warehouseLocation': warehouseLocation,
      'conditionNotes': conditionNotes,
    };
  }
}

/// Return Inspection stage with additional fields
class ReturnInspectionStageInfo extends OrderStageInfo {
  final String? inspectedBy;
  final String? inspectionResult;
  final List<String>? inspectionPhotos;

  ReturnInspectionStageInfo({
    required super.isCompleted,
    super.completedAt,
    super.notes,
    this.inspectedBy,
    this.inspectionResult,
    this.inspectionPhotos,
  });

  factory ReturnInspectionStageInfo.fromJson(Map<String, dynamic> json) {
    return ReturnInspectionStageInfo(
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
      inspectedBy: json['inspectedBy'],
      inspectionResult: json['inspectionResult'],
      inspectionPhotos: json['inspectionPhotos'] != null 
          ? List<String>.from(json['inspectionPhotos'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'inspectedBy': inspectedBy,
      'inspectionResult': inspectionResult,
      'inspectionPhotos': inspectionPhotos,
    };
  }
}

/// Return Processing stage with additional fields
class ReturnProcessingStageInfo extends OrderStageInfo {
  final String? processedBy;
  final String? processingType; // 'refund', 'exchange', 'repair'

  ReturnProcessingStageInfo({
    required super.isCompleted,
    super.completedAt,
    super.notes,
    this.processedBy,
    this.processingType,
  });

  factory ReturnProcessingStageInfo.fromJson(Map<String, dynamic> json) {
    return ReturnProcessingStageInfo(
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
      processedBy: json['processedBy'],
      processingType: json['processingType'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'processedBy': processedBy,
      'processingType': processingType,
    };
  }
}

/// Return To Business stage with additional fields
class ReturnToBusinessStageInfo extends OrderStageInfo {
  final String? assignedCourier;
  final String? assignedBy;

  ReturnToBusinessStageInfo({
    required super.isCompleted,
    super.completedAt,
    super.notes,
    this.assignedCourier,
    this.assignedBy,
  });

  factory ReturnToBusinessStageInfo.fromJson(Map<String, dynamic> json) {
    return ReturnToBusinessStageInfo(
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
      assignedCourier: json['assignedCourier'],
      assignedBy: json['assignedBy'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'assignedCourier': assignedCourier,
      'assignedBy': assignedBy,
    };
  }
}

/// Return Completed stage with additional fields
class ReturnCompletedStageInfo extends OrderStageInfo {
  final String? completedBy;
  final String? businessSignature;
  final String? deliveryLocation;

  ReturnCompletedStageInfo({
    required super.isCompleted,
    super.completedAt,
    super.notes,
    this.completedBy,
    this.businessSignature,
    this.deliveryLocation,
  });

  factory ReturnCompletedStageInfo.fromJson(Map<String, dynamic> json) {
    return ReturnCompletedStageInfo(
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
      completedBy: json['completedBy'],
      businessSignature: json['businessSignature'],
      deliveryLocation: json['deliveryLocation'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'completedBy': completedBy,
      'businessSignature': businessSignature,
      'deliveryLocation': deliveryLocation,
    };
  }
}

/// Returned final stage with additional fields
class ReturnedStageInfo extends OrderStageInfo {
  final bool? returnOrderCompleted;
  final DateTime? returnOrderCompletedAt;

  ReturnedStageInfo({
    required super.isCompleted,
    super.completedAt,
    super.notes,
    this.returnOrderCompleted,
    this.returnOrderCompletedAt,
  });

  factory ReturnedStageInfo.fromJson(Map<String, dynamic> json) {
    return ReturnedStageInfo(
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
      returnOrderCompleted: json['returnOrderCompleted'],
      returnOrderCompletedAt: json['returnOrderCompletedAt'] != null 
          ? DateTime.parse(json['returnOrderCompletedAt'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'returnOrderCompleted': returnOrderCompleted,
      'returnOrderCompletedAt': returnOrderCompletedAt?.toIso8601String(),
    };
  }
}

/// Container for all order stages (both delivery and return)
class OrderStages {
  // Delivery flow stages
  final DeliveryStageInfo? orderPlaced;
  final DeliveryStageInfo? packed;
  final DeliveryStageInfo? shipping;
  final DeliveryStageInfo? inProgress;
  final DeliveryStageInfo? outForDelivery;
  final DeliveryStageInfo? delivered;

  // Return flow stages
  final ReturnInitiatedStageInfo? returnInitiated;
  final ReturnAssignedStageInfo? returnAssigned;
  final ReturnPickedUpStageInfo? returnPickedUp;
  final ReturnAtWarehouseStageInfo? returnAtWarehouse;
  final ReturnInspectionStageInfo? returnInspection;
  final ReturnProcessingStageInfo? returnProcessing;
  final ReturnToBusinessStageInfo? returnToBusiness;
  final ReturnCompletedStageInfo? returnCompleted;
  final ReturnedStageInfo? returned;

  OrderStages({
    this.orderPlaced,
    this.packed,
    this.shipping,
    this.inProgress,
    this.outForDelivery,
    this.delivered,
    this.returnInitiated,
    this.returnAssigned,
    this.returnPickedUp,
    this.returnAtWarehouse,
    this.returnInspection,
    this.returnProcessing,
    this.returnToBusiness,
    this.returnCompleted,
    this.returned,
  });

  factory OrderStages.fromJson(Map<String, dynamic> json) {
    return OrderStages(
      orderPlaced: json['orderPlaced'] != null 
          ? DeliveryStageInfo.fromJson(json['orderPlaced'])
          : null,
      packed: json['packed'] != null 
          ? DeliveryStageInfo.fromJson(json['packed'])
          : null,
      shipping: json['shipping'] != null 
          ? DeliveryStageInfo.fromJson(json['shipping'])
          : null,
      inProgress: json['inProgress'] != null 
          ? DeliveryStageInfo.fromJson(json['inProgress'])
          : null,
      outForDelivery: json['outForDelivery'] != null 
          ? DeliveryStageInfo.fromJson(json['outForDelivery'])
          : null,
      delivered: json['delivered'] != null 
          ? DeliveryStageInfo.fromJson(json['delivered'])
          : null,
      returnInitiated: json['returnInitiated'] != null 
          ? ReturnInitiatedStageInfo.fromJson(json['returnInitiated'])
          : null,
      returnAssigned: json['returnAssigned'] != null 
          ? ReturnAssignedStageInfo.fromJson(json['returnAssigned'])
          : null,
      returnPickedUp: json['returnPickedUp'] != null 
          ? ReturnPickedUpStageInfo.fromJson(json['returnPickedUp'])
          : null,
      returnAtWarehouse: json['returnAtWarehouse'] != null 
          ? ReturnAtWarehouseStageInfo.fromJson(json['returnAtWarehouse'])
          : null,
      returnInspection: json['returnInspection'] != null 
          ? ReturnInspectionStageInfo.fromJson(json['returnInspection'])
          : null,
      returnProcessing: json['returnProcessing'] != null 
          ? ReturnProcessingStageInfo.fromJson(json['returnProcessing'])
          : null,
      returnToBusiness: json['returnToBusiness'] != null 
          ? ReturnToBusinessStageInfo.fromJson(json['returnToBusiness'])
          : null,
      returnCompleted: json['returnCompleted'] != null 
          ? ReturnCompletedStageInfo.fromJson(json['returnCompleted'])
          : null,
      returned: json['returned'] != null 
          ? ReturnedStageInfo.fromJson(json['returned'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (orderPlaced != null) 'orderPlaced': orderPlaced!.toJson(),
      if (packed != null) 'packed': packed!.toJson(),
      if (shipping != null) 'shipping': shipping!.toJson(),
      if (inProgress != null) 'inProgress': inProgress!.toJson(),
      if (outForDelivery != null) 'outForDelivery': outForDelivery!.toJson(),
      if (delivered != null) 'delivered': delivered!.toJson(),
      if (returnInitiated != null) 'returnInitiated': returnInitiated!.toJson(),
      if (returnAssigned != null) 'returnAssigned': returnAssigned!.toJson(),
      if (returnPickedUp != null) 'returnPickedUp': returnPickedUp!.toJson(),
      if (returnAtWarehouse != null) 'returnAtWarehouse': returnAtWarehouse!.toJson(),
      if (returnInspection != null) 'returnInspection': returnInspection!.toJson(),
      if (returnProcessing != null) 'returnProcessing': returnProcessing!.toJson(),
      if (returnToBusiness != null) 'returnToBusiness': returnToBusiness!.toJson(),
      if (returnCompleted != null) 'returnCompleted': returnCompleted!.toJson(),
      if (returned != null) 'returned': returned!.toJson(),
    };
  }
}

/// Courier history entry
class CourierHistoryEntry {
  final String? courier; // ObjectId as string
  final DateTime? assignedAt;
  final String? action; // 'assigned', 'pickup_from_customer', etc.
  final String? notes;

  CourierHistoryEntry({
    this.courier,
    this.assignedAt,
    this.action,
    this.notes,
  });

  factory CourierHistoryEntry.fromJson(Map<String, dynamic> json) {
    return CourierHistoryEntry(
      courier: json['courier'],
      assignedAt: json['assignedAt'] != null 
          ? DateTime.parse(json['assignedAt'])
          : null,
      action: json['action'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courier': courier,
      'assignedAt': assignedAt?.toIso8601String(),
      'action': action,
      'notes': notes,
    };
  }
}

/// Order status history entry
class OrderStatusHistoryEntry {
  final String status;
  final String statusCategory;
  final DateTime changedAt;
  final String? changedBy;
  final String? notes;

  OrderStatusHistoryEntry({
    required this.status,
    required this.statusCategory,
    required this.changedAt,
    this.changedBy,
    this.notes,
  });

  factory OrderStatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryEntry(
      status: json['status'] ?? '',
      statusCategory: json['statusCategory'] ?? '',
      changedAt: json['changedAt'] != null 
          ? DateTime.parse(json['changedAt'])
          : DateTime.now(),
      changedBy: json['changedBy'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'statusCategory': statusCategory,
      'changedAt': changedAt.toIso8601String(),
      'changedBy': changedBy,
      'notes': notes,
    };
  }
}

