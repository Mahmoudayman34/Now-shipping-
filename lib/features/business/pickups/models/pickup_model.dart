// Pickup model for API response
class PickupModel {
  final String id;
  final String pickupNumber;
  final int numberOfOrders;
  final double pickupFees;
  final DateTime pickupDate;
  final String phoneNumber;
  final bool isFragileItems;
  final bool isLargeItems;
  final String pickupStatus;
  final String pickupNotes;
  final List<String> ordersPickedUp;
  final BusinessInfo? business;
  final List<PickupStage> pickupStages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AssignedDriver? assignedDriver;

  PickupModel({
    required this.id,
    required this.pickupNumber,
    required this.numberOfOrders,
    required this.pickupFees,
    required this.pickupDate,
    required this.phoneNumber,
    required this.isFragileItems,
    required this.isLargeItems,
    required this.pickupStatus,
    required this.pickupNotes,
    required this.ordersPickedUp,
    this.business,
    required this.pickupStages,
    required this.createdAt,
    required this.updatedAt,
    this.assignedDriver,
  });

  factory PickupModel.fromJson(Map<String, dynamic> json) {
    return PickupModel(
      id: json['_id'] ?? '',
      pickupNumber: json['pickupNumber'] ?? '',
      numberOfOrders: json['numberOfOrders'] ?? 0,
      pickupFees: (json['pickupFees'] ?? 0).toDouble(),
      pickupDate: DateTime.parse(json['pickupDate'] ?? DateTime.now().toIso8601String()),
      phoneNumber: json['phoneNumber'] ?? '',
      isFragileItems: json['isFragileItems'] ?? false,
      isLargeItems: json['isLargeItems'] ?? false,
      pickupStatus: json['picikupStatus'] ?? json['pickupStatus'] ?? 'new',
      pickupNotes: json['pickupNotes'] ?? '',
      ordersPickedUp: List<String>.from(json['ordersPickedUp'] ?? []),
      business: json['business'] != null ? BusinessInfo.fromJson(json['business']) : null,
      pickupStages: (json['pickupStages'] as List<dynamic>?)
          ?.map((stage) => PickupStage.fromJson(stage))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      assignedDriver: json['assignedDriver'] != null 
          ? AssignedDriver.fromJson(json['assignedDriver']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'pickupNumber': pickupNumber,
      'numberOfOrders': numberOfOrders,
      'pickupFees': pickupFees,
      'pickupDate': pickupDate.toIso8601String(),
      'phoneNumber': phoneNumber,
      'isFragileItems': isFragileItems,
      'isLargeItems': isLargeItems,
      'pickupStatus': pickupStatus,
      'pickupNotes': pickupNotes,
      'ordersPickedUp': ordersPickedUp,
      'business': business?.toJson(),
      'pickupStages': pickupStages.map((stage) => stage.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'assignedDriver': assignedDriver?.toJson(),
    };
  }

  // Helper getters for backward compatibility with existing UI
  String get pickupId => id;
  String get address => business?.pickUpAddress?.addressDetails ?? '';
  String get contactNumber => phoneNumber;
  DateTime get date => pickupDate;
  String get status => _mapStatusToDisplayStatus();
  bool get isFragileItem => isFragileItems;
  bool get isLargeItem => isLargeItems;
  String? get notes => pickupNotes.isEmpty ? null : pickupNotes;

  String _mapStatusToDisplayStatus() {
    switch (pickupStatus.toLowerCase()) {
      case 'new':
      case 'driverassigned':
        return 'Upcoming';
      case 'completed':
      case 'pickedup':
        return 'Picked Up';
      default:
        return 'Upcoming';
    }
  }
}

class BusinessInfo {
  final BrandInfo? brandInfo;
  final PickUpAddress? pickUpAddress;
  final PaymentMethod? paymentMethod;
  final BrandType? brandType;
  final String id;
  final String role;
  final String name;
  final String email;
  final String phoneNumber;
  final bool isNeedStorage;
  final double balance;
  final bool isCompleted;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImage;

  BusinessInfo({
    this.brandInfo,
    this.pickUpAddress,
    this.paymentMethod,
    this.brandType,
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.isNeedStorage,
    required this.balance,
    required this.isCompleted,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.profileImage,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      brandInfo: json['brandInfo'] != null ? BrandInfo.fromJson(json['brandInfo']) : null,
      pickUpAddress: json['pickUpAdress'] != null ? PickUpAddress.fromJson(json['pickUpAdress']) : null,
      paymentMethod: json['paymentMethod'] != null ? PaymentMethod.fromJson(json['paymentMethod']) : null,
      brandType: json['brandType'] != null ? BrandType.fromJson(json['brandType']) : null,
      id: json['_id'] ?? '',
      role: json['role'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isNeedStorage: json['isNeedStorage'] ?? false,
      balance: (json['balance'] ?? 0).toDouble(),
      isCompleted: json['isCompleted'] ?? false,
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brandInfo': brandInfo?.toJson(),
      'pickUpAdress': pickUpAddress?.toJson(),
      'paymentMethod': paymentMethod?.toJson(),
      'brandType': brandType?.toJson(),
      '_id': id,
      'role': role,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'isNeedStorage': isNeedStorage,
      'balance': balance,
      'isCompleted': isCompleted,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profileImage': profileImage,
    };
  }
}

class BrandInfo {
  final List<String> sellingPoints;
  final String brandName;

  BrandInfo({
    required this.sellingPoints,
    required this.brandName,
  });

  factory BrandInfo.fromJson(Map<String, dynamic> json) {
    return BrandInfo(
      sellingPoints: List<String>.from(json['sellingPoints'] ?? []),
      brandName: json['brandName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sellingPoints': sellingPoints,
      'brandName': brandName,
    };
  }
}

class PickUpAddress {
  final String country;
  final String city;
  final String addressDetails;
  final String nearbyLandmark;
  final String pickupPhone;
  final String pickUpPointInMaps;
  final Map<String, dynamic>? coordinates;

  PickUpAddress({
    required this.country,
    required this.city,
    required this.addressDetails,
    required this.nearbyLandmark,
    required this.pickupPhone,
    required this.pickUpPointInMaps,
    this.coordinates,
  });

  factory PickUpAddress.fromJson(Map<String, dynamic> json) {
    return PickUpAddress(
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      addressDetails: json['adressDetails'] ?? '',
      nearbyLandmark: json['nearbyLandmark'] ?? '',
      pickupPhone: json['pickupPhone'] ?? '',
      pickUpPointInMaps: json['pickUpPointInMaps'] ?? '',
      coordinates: json['coordinates'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'city': city,
      'adressDetails': addressDetails,
      'nearbyLandmark': nearbyLandmark,
      'pickupPhone': pickupPhone,
      'pickUpPointInMaps': pickUpPointInMaps,
      'coordinates': coordinates,
    };
  }
}

class PaymentMethod {
  final String paymentChoice;
  final Map<String, dynamic> details;

  PaymentMethod({
    required this.paymentChoice,
    required this.details,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      paymentChoice: json['paymentChoice'] ?? '',
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentChoice': paymentChoice,
      'details': details,
    };
  }
}

class BrandType {
  final String brandChoice;
  final Map<String, dynamic> brandDetails;

  BrandType({
    required this.brandChoice,
    required this.brandDetails,
  });

  factory BrandType.fromJson(Map<String, dynamic> json) {
    return BrandType(
      brandChoice: json['brandChoice'] ?? '',
      brandDetails: Map<String, dynamic>.from(json['brandDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brandChoice': brandChoice,
      'brandDetails': brandDetails,
    };
  }
}

class PickupStage {
  final String id;
  final String stageName;
  final DateTime stageDate;
  final List<StageNote> stageNotes;

  PickupStage({
    required this.id,
    required this.stageName,
    required this.stageDate,
    required this.stageNotes,
  });

  factory PickupStage.fromJson(Map<String, dynamic> json) {
    return PickupStage(
      id: json['_id'] ?? '',
      stageName: json['stageName'] ?? '',
      stageDate: DateTime.parse(json['stageDate'] ?? DateTime.now().toIso8601String()),
      stageNotes: (json['stageNotes'] as List<dynamic>?)
          ?.map((note) => StageNote.fromJson(note))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'stageName': stageName,
      'stageDate': stageDate.toIso8601String(),
      'stageNotes': stageNotes.map((note) => note.toJson()).toList(),
    };
  }
}

class StageNote {
  final String id;
  final String text;
  final DateTime date;

  StageNote({
    required this.id,
    required this.text,
    required this.date,
  });

  factory StageNote.fromJson(Map<String, dynamic> json) {
    return StageNote(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'date': date.toIso8601String(),
    };
  }
}

class AssignedDriver {
  final String id;
  final String courierID;
  final String name;
  final String personalPhoto;
  final String personalEmail;
  final String email;
  final String phoneNumber;
  final String vehicleType;
  final String vehiclePlateNumber;
  final String nationalId;
  final DateTime dateOfBirth;
  final String address;
  final List<String> assignedZones;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLocationTrackingEnabled;
  final CurrentLocation? currentLocation;

  AssignedDriver({
    required this.id,
    required this.courierID,
    required this.name,
    required this.personalPhoto,
    required this.personalEmail,
    required this.email,
    required this.phoneNumber,
    required this.vehicleType,
    required this.vehiclePlateNumber,
    required this.nationalId,
    required this.dateOfBirth,
    required this.address,
    required this.assignedZones,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
    required this.isLocationTrackingEnabled,
    this.currentLocation,
  });

  factory AssignedDriver.fromJson(Map<String, dynamic> json) {
    return AssignedDriver(
      id: json['_id'] ?? '',
      courierID: json['courierID'] ?? '',
      name: json['name'] ?? '',
      personalPhoto: json['personalPhoto'] ?? '',
      personalEmail: json['personalEmail'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      vehiclePlateNumber: json['vehiclePlateNumber'] ?? '',
      nationalId: json['nationalId'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth'] ?? DateTime.now().toIso8601String()),
      address: json['address'] ?? '',
      assignedZones: List<String>.from(json['assignedZones'] ?? []),
      isAvailable: json['isAvailable'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isLocationTrackingEnabled: json['isLocationTrackingEnabled'] ?? false,
      currentLocation: json['currentLocation'] != null 
          ? CurrentLocation.fromJson(json['currentLocation']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'courierID': courierID,
      'name': name,
      'personalPhoto': personalPhoto,
      'personalEmail': personalEmail,
      'email': email,
      'phoneNumber': phoneNumber,
      'vehicleType': vehicleType,
      'vehiclePlateNumber': vehiclePlateNumber,
      'nationalId': nationalId,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'address': address,
      'assignedZones': assignedZones,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isLocationTrackingEnabled': isLocationTrackingEnabled,
      'currentLocation': currentLocation?.toJson(),
    };
  }
}

class CurrentLocation {
  final String type;
  final List<double> coordinates;
  final DateTime lastUpdated;

  CurrentLocation({
    required this.type,
    required this.coordinates,
    required this.lastUpdated,
  });

  factory CurrentLocation.fromJson(Map<String, dynamic> json) {
    return CurrentLocation(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates'] ?? []),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

// New models for picked up orders
class PickedUpOrder {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final double orderFees;
  final String orderStatus;
  final String referralNumber;
  final bool isOrderAvailableForPreview;
  final String orderNotes;
  final OrderCustomer orderCustomer;
  final OrderShipping orderShipping;
  final int attempts;
  final List<String> unavailableReason;
  final List<OrderStage> orderStages;
  final String business;
  final bool orderFullyCompleted;
  final DateTime? completedDate;
  final DateTime? moneyReleaseDate;
  final bool isMoneyReceivedFromCourier;
  final DateTime updatedAt;
  final String? deliveryMan;

  PickedUpOrder({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.orderFees,
    required this.orderStatus,
    required this.referralNumber,
    required this.isOrderAvailableForPreview,
    required this.orderNotes,
    required this.orderCustomer,
    required this.orderShipping,
    required this.attempts,
    required this.unavailableReason,
    required this.orderStages,
    required this.business,
    required this.orderFullyCompleted,
    this.completedDate,
    this.moneyReleaseDate,
    required this.isMoneyReceivedFromCourier,
    required this.updatedAt,
    this.deliveryMan,
  });

  factory PickedUpOrder.fromJson(Map<String, dynamic> json) {
    return PickedUpOrder(
      id: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      orderFees: (json['orderFees'] ?? 0).toDouble(),
      orderStatus: json['orderStatus'] ?? '',
      referralNumber: json['referralNumber'] ?? '',
      isOrderAvailableForPreview: json['isOrderAvailableForPreview'] ?? false,
      orderNotes: json['orderNotes'] ?? '',
      orderCustomer: OrderCustomer.fromJson(json['orderCustomer'] ?? {}),
      orderShipping: OrderShipping.fromJson(json['orderShipping'] ?? {}),
      attempts: json['Attemps'] ?? 0, // Note the typo in API
      unavailableReason: List<String>.from(json['UnavailableReason'] ?? []),
      orderStages: (json['orderStages'] as List<dynamic>?)
          ?.map((stage) => OrderStage.fromJson(stage))
          .toList() ?? [],
      business: json['business'] ?? '',
      orderFullyCompleted: json['orderFullyCompleted'] ?? false,
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate']) 
          : null,
      moneyReleaseDate: json['moneyReleaseDate'] != null 
          ? DateTime.parse(json['moneyReleaseDate']) 
          : null,
      isMoneyReceivedFromCourier: json['isMoneyRecivedFromCourier'] ?? false, // Note the typo in API
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      deliveryMan: json['deliveryMan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderNumber': orderNumber,
      'orderDate': orderDate.toIso8601String(),
      'orderFees': orderFees,
      'orderStatus': orderStatus,
      'referralNumber': referralNumber,
      'isOrderAvailableForPreview': isOrderAvailableForPreview,
      'orderNotes': orderNotes,
      'orderCustomer': orderCustomer.toJson(),
      'orderShipping': orderShipping.toJson(),
      'Attemps': attempts,
      'UnavailableReason': unavailableReason,
      'orderStages': orderStages.map((stage) => stage.toJson()).toList(),
      'business': business,
      'orderFullyCompleted': orderFullyCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'moneyReleaseDate': moneyReleaseDate?.toIso8601String(),
      'isMoneyRecivedFromCourier': isMoneyReceivedFromCourier,
      'updatedAt': updatedAt.toIso8601String(),
      'deliveryMan': deliveryMan,
    };
  }
}

class OrderCustomer {
  final String fullName;
  final String phoneNumber;
  final String address;
  final String government;
  final String zone;

  OrderCustomer({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.government,
    required this.zone,
  });

  factory OrderCustomer.fromJson(Map<String, dynamic> json) {
    return OrderCustomer(
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      government: json['government'] ?? '',
      zone: json['zone'] ?? '',
    );
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
}

class OrderShipping {
  final bool isExpressShipping;
  final String productDescription;
  final int numberOfItems;
  final String productDescriptionReplacement;
  final int numberOfItemsReplacement;
  final String orderType;
  final String amountType;
  final double amount;

  OrderShipping({
    required this.isExpressShipping,
    required this.productDescription,
    required this.numberOfItems,
    required this.productDescriptionReplacement,
    required this.numberOfItemsReplacement,
    required this.orderType,
    required this.amountType,
    required this.amount,
  });

  factory OrderShipping.fromJson(Map<String, dynamic> json) {
    return OrderShipping(
      isExpressShipping: json['isExpressShipping'] ?? false,
      productDescription: json['productDescription'] ?? '',
      numberOfItems: json['numberOfItems'] ?? 0,
      productDescriptionReplacement: json['productDescriptionReplacement'] ?? '',
      numberOfItemsReplacement: json['numberOfItemsReplacement'] ?? 0,
      orderType: json['orderType'] ?? '',
      amountType: json['amountType'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isExpressShipping': isExpressShipping,
      'productDescription': productDescription,
      'numberOfItems': numberOfItems,
      'productDescriptionReplacement': productDescriptionReplacement,
      'numberOfItemsReplacement': numberOfItemsReplacement,
      'orderType': orderType,
      'amountType': amountType,
      'amount': amount,
    };
  }
}

class OrderStage {
  final String id;
  final String stageName;
  final DateTime stageDate;
  final List<StageNote> stageNotes;

  OrderStage({
    required this.id,
    required this.stageName,
    required this.stageDate,
    required this.stageNotes,
  });

  factory OrderStage.fromJson(Map<String, dynamic> json) {
    return OrderStage(
      id: json['_id'] ?? '',
      stageName: json['stageName'] ?? '',
      stageDate: DateTime.parse(json['stageDate'] ?? DateTime.now().toIso8601String()),
      stageNotes: (json['stageNotes'] as List<dynamic>?)
          ?.map((note) => StageNote.fromJson(note))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'stageName': stageName,
      'stageDate': stageDate.toIso8601String(),
      'stageNotes': stageNotes.map((note) => note.toJson()).toList(),
    };
  }
}