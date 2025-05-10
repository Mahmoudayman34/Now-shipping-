class OrderModel {
  String? id;
  String? customerName;
  String? customerPhone;
  String? customerAddress;
  String? deliveryType;
  String? productDescription;
  int? numberOfItems;
  int? numberOfNewItems;
  int? numberOfReturnItems;
  bool? cashOnDelivery;
  bool? allowPackageInspection;
  String? specialInstructions;
  String? referralNumber;
  String? amountToCollect;
  DateTime? createdAt;
  String? status;

  OrderModel({
    this.id,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.deliveryType = 'Deliver',
    this.productDescription,
    this.numberOfItems = 1,
    this.numberOfNewItems = 1,
    this.numberOfReturnItems = 1,
    this.cashOnDelivery = false,
    this.allowPackageInspection = false,
    this.specialInstructions,
    this.referralNumber,
    this.amountToCollect,
    this.createdAt,
    this.status = 'Pending',
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
      'numberOfItems': numberOfItems,
      'numberOfNewItems': numberOfNewItems,
      'numberOfReturnItems': numberOfReturnItems,
      'cashOnDelivery': cashOnDelivery,
      'allowPackageInspection': allowPackageInspection,
      'specialInstructions': specialInstructions,
      'referralNumber': referralNumber,
      'amountToCollect': amountToCollect,
      'createdAt': createdAt?.toIso8601String(),
      'status': status,
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
      numberOfItems: map['numberOfItems'],
      numberOfNewItems: map['numberOfNewItems'],
      numberOfReturnItems: map['numberOfReturnItems'],
      cashOnDelivery: map['cashOnDelivery'],
      allowPackageInspection: map['allowPackageInspection'],
      specialInstructions: map['specialInstructions'],
      referralNumber: map['referralNumber'],
      amountToCollect: map['amountToCollect'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      status: map['status'],
    );
  }
}

