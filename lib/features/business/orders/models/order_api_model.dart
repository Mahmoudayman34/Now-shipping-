import 'package:now_shipping/core/constants/order_constants.dart';
import 'package:now_shipping/features/business/orders/models/order_stage_model.dart';
import 'package:now_shipping/features/business/pickups/models/pickup_model.dart';

/// Comprehensive API Order Model matching the new backend structure
class ApiOrderModel {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final double orderFees;
  
  // Status fields
  final String orderStatus;
  final OrderStatusCategory statusCategory;
  final List<OrderStatusHistoryEntry> orderStatusHistory;
  
  final String referralNumber;
  final bool isOrderAvailableForPreview;
  final String orderNotes;
  
  // Customer information
  final OrderCustomer orderCustomer;
  
  // Shipping information
  final OrderShipping orderShipping;
  
  // Delivery tracking
  final int attempts;
  final List<String> unavailableReason;
  
  // Order stages (new structure)
  final OrderStages orderStages;
  
  // Courier information
  final List<CourierHistoryEntry> courierHistory;
  final String? deliveryMan;
  
  // Business reference
  final String business;
  
  // Completion status
  final bool orderFullyCompleted;
  final DateTime? completedDate;
  final DateTime? moneyReleaseDate;
  final bool isMoneyReceivedFromCourier;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  ApiOrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.orderFees,
    required this.orderStatus,
    required this.statusCategory,
    required this.orderStatusHistory,
    required this.referralNumber,
    required this.isOrderAvailableForPreview,
    required this.orderNotes,
    required this.orderCustomer,
    required this.orderShipping,
    required this.attempts,
    required this.unavailableReason,
    required this.orderStages,
    required this.courierHistory,
    this.deliveryMan,
    required this.business,
    required this.orderFullyCompleted,
    this.completedDate,
    this.moneyReleaseDate,
    required this.isMoneyReceivedFromCourier,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiOrderModel.fromJson(Map<String, dynamic> json) {
    final status = json['orderStatus'] ?? 'new';
    
    return ApiOrderModel(
      id: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      orderFees: (json['orderFees'] ?? 0).toDouble(),
      orderStatus: status,
      statusCategory: OrderStatus.getCategory(status),
      orderStatusHistory: (json['orderStatusHistory'] as List<dynamic>?)
          ?.map((entry) => OrderStatusHistoryEntry.fromJson(entry))
          .toList() ?? [],
      referralNumber: json['referralNumber'] ?? '',
      isOrderAvailableForPreview: json['isOrderAvailableForPreview'] ?? false,
      orderNotes: json['orderNotes'] ?? '',
      orderCustomer: OrderCustomer.fromJson(json['orderCustomer'] ?? {}),
      orderShipping: OrderShipping.fromJson(json['orderShipping'] ?? {}),
      attempts: json['Attemps'] ?? json['attempts'] ?? 0, // Handle typo in API
      unavailableReason: List<String>.from(json['UnavailableReason'] ?? json['unavailableReason'] ?? []),
      orderStages: OrderStages.fromJson(json['orderStages'] ?? {}),
      courierHistory: (json['courierHistory'] as List<dynamic>?)
          ?.map((entry) => CourierHistoryEntry.fromJson(entry))
          .toList() ?? [],
      deliveryMan: json['deliveryMan'],
      business: json['business'] ?? '',
      orderFullyCompleted: json['orderFullyCompleted'] ?? false,
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate'])
          : null,
      moneyReleaseDate: json['moneyReleaseDate'] != null 
          ? DateTime.parse(json['moneyReleaseDate'])
          : null,
      isMoneyReceivedFromCourier: json['isMoneyRecivedFromCourier'] ?? json['isMoneyReceivedFromCourier'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderNumber': orderNumber,
      'orderDate': orderDate.toIso8601String(),
      'orderFees': orderFees,
      'orderStatus': orderStatus,
      'statusCategory': statusCategory.value,
      'orderStatusHistory': orderStatusHistory.map((e) => e.toJson()).toList(),
      'referralNumber': referralNumber,
      'isOrderAvailableForPreview': isOrderAvailableForPreview,
      'orderNotes': orderNotes,
      'orderCustomer': orderCustomer.toJson(),
      'orderShipping': orderShipping.toJson(),
      'Attemps': attempts,
      'UnavailableReason': unavailableReason,
      'orderStages': orderStages.toJson(),
      'courierHistory': courierHistory.map((e) => e.toJson()).toList(),
      'deliveryMan': deliveryMan,
      'business': business,
      'orderFullyCompleted': orderFullyCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'moneyReleaseDate': moneyReleaseDate?.toIso8601String(),
      'isMoneyRecivedFromCourier': isMoneyReceivedFromCourier,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Helper getters for UI
  String get displayStatus => OrderStatus.getDisplayName(orderStatus);
  String get statusDescription => OrderStatus.getDescription(orderStatus);
  bool get isReturnOrder => orderShipping.orderType == 'Return';
  bool get isDeliveryOrder => orderShipping.orderType == 'Deliver';
  bool get isExchangeOrder => orderShipping.orderType == 'Exchange';
  bool get isCashCollectionOrder => orderShipping.orderType == 'Cash Collection';
  
  /// Check if order is in a specific category
  bool get isNew => statusCategory == OrderStatusCategory.newOrder;
  bool get isProcessing => statusCategory == OrderStatusCategory.processing;
  bool get isPaused => statusCategory == OrderStatusCategory.paused;
  bool get isSuccessful => statusCategory == OrderStatusCategory.successful;
  bool get isUnsuccessful => statusCategory == OrderStatusCategory.unsuccessful;
}

