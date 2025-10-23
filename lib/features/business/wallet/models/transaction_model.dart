class TransactionModel {
  final String id;
  final String transactionId;
  final String transactionType;
  final double transactionAmount;
  final String? transactionNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool settled;
  final String settlementStatus;
  final List<OrderReference>? orderReferences;
  final List<PickupReference>? pickupReferences;
  final int orderCount;
  final int pickupCount;
  final double totalOrderAmount;
  final double totalOrderFees;
  final double totalPickupFees;

  const TransactionModel({
    required this.id,
    required this.transactionId,
    required this.transactionType,
    required this.transactionAmount,
    this.transactionNotes,
    required this.createdAt,
    required this.updatedAt,
    required this.settled,
    required this.settlementStatus,
    this.orderReferences,
    this.pickupReferences,
    required this.orderCount,
    required this.pickupCount,
    required this.totalOrderAmount,
    required this.totalOrderFees,
    required this.totalPickupFees,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? '',
      transactionId: json['transactionId'] ?? '',
      transactionType: json['transactionType'] ?? '',
      transactionAmount: (json['transactionAmount'] ?? 0).toDouble(),
      transactionNotes: json['transactionNotes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      settled: json['settled'] ?? false,
      settlementStatus: json['settlementStatus'] ?? '',
      orderReferences: json['orderReferences'] != null 
          ? (json['orderReferences'] as List).map((e) => OrderReference.fromJson(e)).toList()
          : null,
      pickupReferences: json['pickupReferences'] != null 
          ? (json['pickupReferences'] as List).map((e) => PickupReference.fromJson(e)).toList()
          : null,
      orderCount: json['orderCount'] ?? 0,
      pickupCount: json['pickupCount'] ?? 0,
      totalOrderAmount: (json['totalOrderAmount'] ?? 0).toDouble(),
      totalOrderFees: (json['totalOrderFees'] ?? 0).toDouble(),
      totalPickupFees: (json['totalPickupFees'] ?? 0).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'transactionId': transactionId,
      'transactionType': transactionType,
      'transactionAmount': transactionAmount,
      'transactionNotes': transactionNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'settled': settled,
      'settlementStatus': settlementStatus,
      'orderReferences': orderReferences?.map((e) => e.toJson()).toList(),
      'pickupReferences': pickupReferences?.map((e) => e.toJson()).toList(),
      'orderCount': orderCount,
      'pickupCount': pickupCount,
      'totalOrderAmount': totalOrderAmount,
      'totalOrderFees': totalOrderFees,
      'totalPickupFees': totalPickupFees,
    };
  }

  // Helper methods for UI display
  String get formattedAmount {
    final sign = transactionAmount >= 0 ? '+' : '';
    return '$sign${transactionAmount.toStringAsFixed(0)} EGP';
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get displayType {
    switch (transactionType) {
      case 'cashCycle':
        return 'Cash Cycle';
      case 'fees':
        return 'Service Fees';
      case 'pickupFees':
        return 'Pickup Fees';
      case 'refund':
        return 'Refund';
      case 'deposit':
        return 'Deposit';
      case 'withdrawal':
        return 'Withdrawal';
      default:
        return transactionType;
    }
  }

  String get statusDisplay {
    if (settled) {
      return 'Settled (Released to account)';
    }
    return 'Pending';
  }

  bool get isPositive => transactionAmount >= 0;
}

class OrderReference {
  final OrderDetails orderId;

  const OrderReference({required this.orderId});

  factory OrderReference.fromJson(Map<String, dynamic> json) {
    return OrderReference(
      orderId: OrderDetails.fromJson(json['orderId'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId.toJson(),
    };
  }
}

class OrderDetails {
  final String id;
  final String orderNumber;
  final OrderShipping? orderShipping;
  final double orderFees;
  final DateTime? completedDate;

  const OrderDetails({
    required this.id,
    required this.orderNumber,
    this.orderShipping,
    required this.orderFees,
    this.completedDate,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      orderShipping: json['orderShipping'] != null 
          ? OrderShipping.fromJson(json['orderShipping'])
          : null,
      orderFees: (json['orderFees'] ?? 0).toDouble(),
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderNumber': orderNumber,
      'orderShipping': orderShipping?.toJson(),
      'orderFees': orderFees,
      'completedDate': completedDate?.toIso8601String(),
    };
  }
}

class OrderShipping {
  final String orderType;

  const OrderShipping({required this.orderType});

  factory OrderShipping.fromJson(Map<String, dynamic> json) {
    return OrderShipping(
      orderType: json['orderType'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'orderType': orderType,
    };
  }
}

class PickupReference {
  final PickupDetails pickupId;

  const PickupReference({required this.pickupId});

  factory PickupReference.fromJson(Map<String, dynamic> json) {
    return PickupReference(
      pickupId: PickupDetails.fromJson(json['pickupId'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'pickupId': pickupId.toJson(),
    };
  }
}

class PickupDetails {
  final String id;
  final String pickupNumber;
  final double pickupFees;

  const PickupDetails({
    required this.id,
    required this.pickupNumber,
    required this.pickupFees,
  });

  factory PickupDetails.fromJson(Map<String, dynamic> json) {
    return PickupDetails(
      id: json['_id'] ?? '',
      pickupNumber: json['pickupNumber'] ?? '',
      pickupFees: (json['pickupFees'] ?? 0).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'pickupNumber': pickupNumber,
      'pickupFees': pickupFees,
    };
  }
}
