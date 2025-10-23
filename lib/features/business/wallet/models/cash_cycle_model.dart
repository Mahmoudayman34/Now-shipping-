class CashCycleModel {
  final double totalIncome;
  final double totalFees;
  final double transactionFees;
  final double netTotal;
  final int inProgressCount;
  final int completedCount;
  final int completedOrdersCount;
  final int returnedOrdersCount;
  final int canceledOrdersCount;
  final int returnCompletedOrdersCount;
  final List<CashCycleOrder> orders;
  final List<CashCycleTransaction> transactions;
  final CashCycleDebug? debug;

  const CashCycleModel({
    required this.totalIncome,
    required this.totalFees,
    required this.transactionFees,
    required this.netTotal,
    required this.inProgressCount,
    required this.completedCount,
    required this.completedOrdersCount,
    required this.returnedOrdersCount,
    required this.canceledOrdersCount,
    required this.returnCompletedOrdersCount,
    required this.orders,
    required this.transactions,
    this.debug,
  });

  factory CashCycleModel.fromJson(Map<String, dynamic> json) {
    try {
      print('CASH CYCLE MODEL: Parsing JSON with keys: ${json.keys.toList()}');
      print('CASH CYCLE MODEL: totalIncome: ${json['totalIncome']}');
      print('CASH CYCLE MODEL: orders count: ${json['orders']?.length ?? 0}');
      
      final model = CashCycleModel(
        totalIncome: (json['totalIncome'] ?? 0).toDouble(),
        totalFees: (json['totalFees'] ?? 0).toDouble(),
        transactionFees: (json['transactionFees'] ?? 0).toDouble(),
        netTotal: (json['netTotal'] ?? 0).toDouble(),
        inProgressCount: json['inProgressCount'] ?? 0,
        completedCount: json['completedCount'] ?? 0,
        completedOrdersCount: json['completedOrdersCount'] ?? 0,
        returnedOrdersCount: json['returnedOrdersCount'] ?? 0,
        canceledOrdersCount: json['canceledOrdersCount'] ?? 0,
        returnCompletedOrdersCount: json['returnCompletedOrdersCount'] ?? 0,
        orders: json['orders'] != null 
            ? (json['orders'] as List).map((e) => CashCycleOrder.fromJson(e)).toList()
            : [],
        transactions: json['transactions'] != null 
            ? (json['transactions'] as List).map((e) => CashCycleTransaction.fromJson(e)).toList()
            : [],
        debug: json['debug'] != null ? CashCycleDebug.fromJson(json['debug']) : null,
      );
      
      print('CASH CYCLE MODEL: Successfully created model with ${model.orders.length} orders');
      return model;
    } catch (e, stackTrace) {
      print('CASH CYCLE MODEL ERROR: $e');
      print('CASH CYCLE MODEL STACK: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'totalIncome': totalIncome,
      'totalFees': totalFees,
      'transactionFees': transactionFees,
      'netTotal': netTotal,
      'inProgressCount': inProgressCount,
      'completedCount': completedCount,
      'completedOrdersCount': completedOrdersCount,
      'returnedOrdersCount': returnedOrdersCount,
      'canceledOrdersCount': canceledOrdersCount,
      'returnCompletedOrdersCount': returnCompletedOrdersCount,
      'orders': orders.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'debug': debug?.toJson(),
    };
  }

  // Helper methods for UI display
  String get formattedTotalIncome => '${totalIncome.toStringAsFixed(2)} EGP';
  String get formattedTotalFees => '${totalFees.toStringAsFixed(2)} EGP';
  String get formattedNetTotal => '${netTotal.toStringAsFixed(2)} EGP';
  String get formattedTransactionFees => '${transactionFees.toStringAsFixed(2)} EGP';
}

class CashCycleOrder {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final DateTime completedDate;
  final String orderStatus;
  final CashCycleCustomer orderCustomer;
  final CashCycleShipping orderShipping;
  final double orderFees;
  final CashCycleDeliveryMan? deliveryMan;
  final DateTime? moneyReleaseDate;
  final String releaseStatus;

  const CashCycleOrder({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.completedDate,
    required this.orderStatus,
    required this.orderCustomer,
    required this.orderShipping,
    required this.orderFees,
    this.deliveryMan,
    this.moneyReleaseDate,
    required this.releaseStatus,
  });

  factory CashCycleOrder.fromJson(Map<String, dynamic> json) {
    try {
      print('CASH CYCLE ORDER: Parsing order ${json['orderNumber']}');
      
      // Handle missing completedDate - use orderDate as fallback
      DateTime completedDate;
      if (json['completedDate'] != null) {
        completedDate = DateTime.parse(json['completedDate']);
      } else {
        print('CASH CYCLE ORDER: No completedDate for order ${json['orderNumber']}, using orderDate');
        completedDate = DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String());
      }
      
      final order = CashCycleOrder(
        id: json['_id'] ?? '',
        orderNumber: json['orderNumber'] ?? '',
        orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
        completedDate: completedDate,
        orderStatus: json['orderStatus'] ?? '',
        orderCustomer: CashCycleCustomer.fromJson(json['orderCustomer'] ?? {}),
        orderShipping: CashCycleShipping.fromJson(json['orderShipping'] ?? {}),
        orderFees: (json['orderFees'] ?? 0).toDouble(),
        deliveryMan: json['deliveryMan'] != null 
            ? CashCycleDeliveryMan.fromJson(json['deliveryMan'])
            : null,
        moneyReleaseDate: json['moneyReleaseDate'] != null 
            ? DateTime.parse(json['moneyReleaseDate'])
            : null,
        releaseStatus: json['releaseStatus'] ?? 'pending',
      );
      
      print('CASH CYCLE ORDER: Successfully parsed order ${order.orderNumber}');
      return order;
    } catch (e, stackTrace) {
      print('CASH CYCLE ORDER ERROR: $e');
      print('CASH CYCLE ORDER STACK: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderNumber': orderNumber,
      'orderDate': orderDate.toIso8601String(),
      'completedDate': completedDate.toIso8601String(),
      'orderStatus': orderStatus,
      'orderCustomer': orderCustomer.toJson(),
      'orderShipping': orderShipping.toJson(),
      'orderFees': orderFees,
      'deliveryMan': deliveryMan?.toJson(),
      'moneyReleaseDate': moneyReleaseDate?.toIso8601String(),
      'releaseStatus': releaseStatus,
    };
  }

  // Helper methods for UI display
  String get formattedOrderNumber => '#$orderNumber';
  String get formattedOrderDate => _formatDate(orderDate);
  String get formattedCompletedDate => _formatDate(completedDate);
  String get formattedMoneyReleaseDate => moneyReleaseDate != null ? _formatDate(moneyReleaseDate!) : 'N/A';
  String get formattedOrderFees => '${orderFees.toStringAsFixed(2)} EGP';
  String get formattedOrderValue => orderShipping.amount != null 
      ? '${orderShipping.amount!.toStringAsFixed(2)} EGP ${orderShipping.amountType}'
      : '0.00 EGP ${orderShipping.amountType}';

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String get statusDisplay {
    switch (orderStatus) {
      case 'completed':
        return 'Completed';
      case 'canceled':
        return 'Canceled';
      case 'returned':
        return 'Returned';
      case 'returnCompleted':
        return 'Return Completed';
      case 'inProgress':
        return 'In Progress';
      default:
        return orderStatus;
    }
  }

  String get releaseStatusDisplay {
    switch (releaseStatus) {
      case 'released':
        return 'Payment Released';
      case 'pending':
        return 'Payment Pending';
      default:
        return releaseStatus;
    }
  }
}

class CashCycleCustomer {
  final String fullName;
  final String phoneNumber;
  final String address;
  final String government;
  final String zone;

  const CashCycleCustomer({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.government,
    required this.zone,
  });

  factory CashCycleCustomer.fromJson(Map<String, dynamic> json) {
    try {
      return CashCycleCustomer(
        fullName: json['fullName'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        address: json['address'] ?? '',
        government: json['government'] ?? '',
        zone: json['zone'] ?? '',
      );
    } catch (e) {
      print('CASH CYCLE CUSTOMER ERROR: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'government': government,
      'zone': zone,
    };
  }

  String get displayLocation => '$government $zone';
}

class CashCycleShipping {
  final String productDescription;
  final int numberOfItems;
  final String productDescriptionReplacement;
  final int numberOfItemsReplacement;
  final String orderType;
  final String amountType;
  final bool isExpressShipping;
  final String? returnReason;
  final String? returnNotes;
  final String? originalOrderNumber;
  final bool isPartialReturn;
  final int? originalOrderItemCount;
  final int? partialReturnItemCount;
  final double returnValue;
  final List<String> returnPhotos;
  final double refundAmount;
  final double? amount;
  final String? linkedReturnOrder;
  final String? returnOrderCode;
  final String? linkedDeliverOrder;

  const CashCycleShipping({
    required this.productDescription,
    required this.numberOfItems,
    required this.productDescriptionReplacement,
    required this.numberOfItemsReplacement,
    required this.orderType,
    required this.amountType,
    required this.isExpressShipping,
    this.returnReason,
    this.returnNotes,
    this.originalOrderNumber,
    required this.isPartialReturn,
    this.originalOrderItemCount,
    this.partialReturnItemCount,
    required this.returnValue,
    required this.returnPhotos,
    required this.refundAmount,
    this.amount,
    this.linkedReturnOrder,
    this.returnOrderCode,
    this.linkedDeliverOrder,
  });

  factory CashCycleShipping.fromJson(Map<String, dynamic> json) {
    try {
      return CashCycleShipping(
        productDescription: json['productDescription'] ?? '',
        numberOfItems: json['numberOfItems'] ?? 0,
        productDescriptionReplacement: json['productDescriptionReplacement'] ?? '',
        numberOfItemsReplacement: json['numberOfItemsReplacement'] ?? 0,
        orderType: json['orderType'] ?? '',
        amountType: json['amountType'] ?? '',
        isExpressShipping: json['isExpressShipping'] ?? false,
        returnReason: json['returnReason'],
        returnNotes: json['returnNotes'],
        originalOrderNumber: json['originalOrderNumber'],
        isPartialReturn: json['isPartialReturn'] ?? false,
        originalOrderItemCount: json['originalOrderItemCount'],
        partialReturnItemCount: json['partialReturnItemCount'],
        returnValue: (json['returnValue'] ?? 0).toDouble(),
        returnPhotos: json['returnPhotos'] != null 
            ? List<String>.from(json['returnPhotos'])
            : [],
        refundAmount: (json['refundAmount'] ?? 0).toDouble(),
        amount: json['amount']?.toDouble(),
        linkedReturnOrder: json['linkedReturnOrder'],
        returnOrderCode: json['returnOrderCode'],
        linkedDeliverOrder: json['linkedDeliverOrder'],
      );
    } catch (e) {
      print('CASH CYCLE SHIPPING ERROR: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'productDescription': productDescription,
      'numberOfItems': numberOfItems,
      'productDescriptionReplacement': productDescriptionReplacement,
      'numberOfItemsReplacement': numberOfItemsReplacement,
      'orderType': orderType,
      'amountType': amountType,
      'isExpressShipping': isExpressShipping,
      'returnReason': returnReason,
      'returnNotes': returnNotes,
      'originalOrderNumber': originalOrderNumber,
      'isPartialReturn': isPartialReturn,
      'originalOrderItemCount': originalOrderItemCount,
      'partialReturnItemCount': partialReturnItemCount,
      'returnValue': returnValue,
      'returnPhotos': returnPhotos,
      'refundAmount': refundAmount,
      'amount': amount,
      'linkedReturnOrder': linkedReturnOrder,
      'returnOrderCode': returnOrderCode,
      'linkedDeliverOrder': linkedDeliverOrder,
    };
  }
}

class CashCycleDeliveryMan {
  final String id;
  final String name;

  const CashCycleDeliveryMan({
    required this.id,
    required this.name,
  });

  factory CashCycleDeliveryMan.fromJson(Map<String, dynamic> json) {
    return CashCycleDeliveryMan(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class CashCycleTransaction {
  final String id;
  final String transactionId;
  final String transactionType;
  final double transactionAmount;
  final String? transactionNotes;
  final DateTime createdAt;
  final List<String> orderReferences;
  final List<String> pickupReferences;
  final Map<String, dynamic>? ordersDetails;

  const CashCycleTransaction({
    required this.id,
    required this.transactionId,
    required this.transactionType,
    required this.transactionAmount,
    this.transactionNotes,
    required this.createdAt,
    required this.orderReferences,
    required this.pickupReferences,
    this.ordersDetails,
  });

  factory CashCycleTransaction.fromJson(Map<String, dynamic> json) {
    try {
      print('CASH CYCLE TRANSACTION: Parsing transaction ${json['transactionId']}');
      print('CASH CYCLE TRANSACTION: orderReferences type: ${json['orderReferences']?.runtimeType}');
      print('CASH CYCLE TRANSACTION: pickupReferences type: ${json['pickupReferences']?.runtimeType}');
      
      // Handle orderReferences - could be List<String> or List<Map>
      List<String> orderRefs = [];
      if (json['orderReferences'] != null) {
        if (json['orderReferences'] is List) {
          for (var item in json['orderReferences']) {
            if (item is String) {
              orderRefs.add(item);
            } else if (item is Map) {
              // Extract relevant string from map if needed
              orderRefs.add(item.toString());
            }
          }
        }
      }
      
      // Handle pickupReferences - could be List<String> or List<Map>
      List<String> pickupRefs = [];
      if (json['pickupReferences'] != null) {
        if (json['pickupReferences'] is List) {
          for (var item in json['pickupReferences']) {
            if (item is String) {
              pickupRefs.add(item);
            } else if (item is Map) {
              // Extract relevant string from map if needed
              pickupRefs.add(item.toString());
            }
          }
        }
      }
      
      return CashCycleTransaction(
        id: json['_id'] ?? '',
        transactionId: json['transactionId'] ?? '',
        transactionType: json['transactionType'] ?? '',
        transactionAmount: (json['transactionAmount'] ?? 0).toDouble(),
        transactionNotes: json['transactionNotes'],
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
        orderReferences: orderRefs,
        pickupReferences: pickupRefs,
        ordersDetails: json['ordersDetails'],
      );
    } catch (e) {
      print('CASH CYCLE TRANSACTION ERROR: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'transactionId': transactionId,
      'transactionType': transactionType,
      'transactionAmount': transactionAmount,
      'transactionNotes': transactionNotes,
      'createdAt': createdAt.toIso8601String(),
      'orderReferences': orderReferences,
      'pickupReferences': pickupReferences,
      'ordersDetails': ordersDetails,
    };
  }
}

class CashCycleDebug {
  final int totalOrdersForBusiness;
  final List<OrderStatusCount> orderStatuses;
  final String timePeriod;
  final Map<String, dynamic> dateFilter;
  final List<CashCycleRelease> releases;

  const CashCycleDebug({
    required this.totalOrdersForBusiness,
    required this.orderStatuses,
    required this.timePeriod,
    required this.dateFilter,
    required this.releases,
  });

  factory CashCycleDebug.fromJson(Map<String, dynamic> json) {
    try {
      return CashCycleDebug(
        totalOrdersForBusiness: json['totalOrdersForBusiness'] ?? 0,
        orderStatuses: json['orderStatuses'] != null 
            ? (json['orderStatuses'] as List).map((e) => OrderStatusCount.fromJson(e)).toList()
            : [],
        timePeriod: json['timePeriod'] ?? '',
        dateFilter: json['dateFilter'] ?? {},
        releases: json['releases'] != null 
            ? (json['releases'] as List).map((e) => CashCycleRelease.fromJson(e)).toList()
            : [],
      );
    } catch (e) {
      print('CASH CYCLE DEBUG ERROR: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrdersForBusiness': totalOrdersForBusiness,
      'orderStatuses': orderStatuses.map((e) => e.toJson()).toList(),
      'timePeriod': timePeriod,
      'dateFilter': dateFilter,
      'releases': releases.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderStatusCount {
  final String id;
  final int count;

  const OrderStatusCount({
    required this.id,
    required this.count,
  });

  factory OrderStatusCount.fromJson(Map<String, dynamic> json) {
    return OrderStatusCount(
      id: json['_id'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'count': count,
    };
  }
}

class CashCycleRelease {
  final String id;
  final String status;
  final double amount;
  final Map<String, dynamic>? dateRange;

  const CashCycleRelease({
    required this.id,
    required this.status,
    required this.amount,
    this.dateRange,
  });

  factory CashCycleRelease.fromJson(Map<String, dynamic> json) {
    return CashCycleRelease(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      dateRange: json['dateRange'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'amount': amount,
      'dateRange': dateRange,
    };
  }
}
