// A simple model for pickup data
class PickupModel {
  final String pickupId;
  final String address;
  final String contactNumber;
  final DateTime pickupDate;
  final String status; // "Upcoming" or "Picked Up"
  final bool isFragileItem;
  final bool isLargeItem;
  final String? notes;

  PickupModel({
    required this.pickupId,
    required this.address,
    required this.contactNumber,
    required this.pickupDate,
    required this.status,
    this.isFragileItem = false,
    this.isLargeItem = false,
    this.notes,
  });
}