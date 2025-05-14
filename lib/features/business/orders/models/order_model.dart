class OrderModel {
  String? id;
  String? customerName;
  String? customerPhone;
  String? customerAddress;
  String? deliveryType;
  String? productDescription;
  String? newProductDescription;
  int? numberOfItems;
  int? numberOfNewItems;
  int? numberOfReturnItems;  
  bool? cashOnDelivery;
  String? cashOnDeliveryAmount;
  bool? hasCashDifference;
  String? cashDifferenceAmount;
  bool? allowPackageInspection;
  String? specialInstructions;
  String? referralNumber;
  String? amountToCollect;
  DateTime? createdAt;
  String? status;
  bool? expressShipping;

  OrderModel({
    this.id,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.deliveryType = 'Deliver',
    this.productDescription,
    this.newProductDescription,
    this.numberOfItems = 1,
    this.numberOfNewItems = 1,    
    this.numberOfReturnItems = 1,
    this.cashOnDelivery = false,
    this.cashOnDeliveryAmount,
    this.hasCashDifference = false,
    this.cashDifferenceAmount,
    this.allowPackageInspection = false,
    this.specialInstructions,
    this.referralNumber,
    this.amountToCollect,
    this.createdAt,
    this.status = 'Pending',
    this.expressShipping = false,
  });

  // Convert to Map for storing in database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'deliveryType': deliveryType,
      'productDescription': productDescription,
      'newProductDescription': newProductDescription,
      'numberOfItems': numberOfItems,      
      'numberOfNewItems': numberOfNewItems,
      'numberOfReturnItems': numberOfReturnItems,
      'cashOnDelivery': cashOnDelivery,
      'cashOnDeliveryAmount': cashOnDeliveryAmount,
      'hasCashDifference': hasCashDifference,
      'cashDifferenceAmount': cashDifferenceAmount,
      'allowPackageInspection': allowPackageInspection,
      'specialInstructions': specialInstructions,
      'referralNumber': referralNumber,
      'amountToCollect': amountToCollect,
      'createdAt': createdAt?.toIso8601String(),
      'status': status,
      'expressShipping': expressShipping,
    };
  }

  // Create OrderModel from Map
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      customerAddress: map['customerAddress'],
      deliveryType: map['deliveryType'],
      productDescription: map['productDescription'],
      newProductDescription: map['newProductDescription'],
      numberOfItems: map['numberOfItems'],
      numberOfNewItems: map['numberOfNewItems'],
      numberOfReturnItems: map['numberOfReturnItems'],
      cashOnDelivery: map['cashOnDelivery'],
      cashOnDeliveryAmount: map['cashOnDeliveryAmount'],
      hasCashDifference: map['hasCashDifference'],
      cashDifferenceAmount: map['cashDifferenceAmount'],
      allowPackageInspection: map['allowPackageInspection'],
      specialInstructions: map['specialInstructions'],
      referralNumber: map['referralNumber'],
      amountToCollect: map['amountToCollect'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      status: map['status'],
      expressShipping: map['expressShipping'],
    );
  }
}

