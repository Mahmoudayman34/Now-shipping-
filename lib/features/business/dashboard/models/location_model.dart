class LocationData {
  final double latitude;
  final double longitude;
  final String? formattedAddress;
  final String? addressDetails;
  final String? country;
  final String? city;
  final String? region;
  final String? zone;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
    this.addressDetails,
    this.country,
    this.city,
    this.region,
    this.zone,
  });

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $formattedAddress, details: $addressDetails)';
  }
}