class PickupAddress {
  String? id;
  String addressName;
  String? addressDetails;
  String? nearbyLandmark;
  String? phoneNumber;
  String? otherPhoneNumber;
  String? country;
  String? region;
  String? zone;
  double? latitude;
  double? longitude;
  String? formattedAddress;

  PickupAddress({
    this.id,
    required this.addressName,
    this.addressDetails,
    this.nearbyLandmark,
    this.phoneNumber,
    this.otherPhoneNumber,
    this.country,
    this.region,
    this.zone,
    this.latitude,
    this.longitude,
    this.formattedAddress,
  });

  Map<String, dynamic> toJson() {
    // Generate Google Maps link from coordinates
    String? googleMapsLink;
    if (latitude != null && longitude != null) {
      googleMapsLink = 'https://www.google.com/maps?q=$latitude,$longitude';
    } else if (formattedAddress != null && formattedAddress!.isNotEmpty) {
      googleMapsLink = formattedAddress;
    }
    
    // Build coordinates object
    Map<String, dynamic>? coordinatesObj;
    if (latitude != null && longitude != null) {
      coordinatesObj = {
        'lat': latitude,
        'lng': longitude,
      };
    }
    
    // Determine if this is the default address (first address or named "Main Address")
    final isDefault = addressName == 'Main Address' || (id != null && id!.contains('main'));
    
    return {
      'id': id,
      'addressName': addressName,
      'addressDetails': addressDetails,
      'adressDetails': addressDetails, // API typo - include both
      'nearbyLandmark': nearbyLandmark,
      'phoneNumber': phoneNumber,
      'otherPhoneNumber': otherPhoneNumber,
      'country': country,
      'region': region,
      'city': region, // For API compatibility
      'zone': zone,
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
      'addressLine1': addressDetails, // For API compatibility
      'pickupPhone': phoneNumber, // For API compatibility
      'otherPickupPhone': otherPhoneNumber, // For API compatibility
      'pickupLocationString': formattedAddress, // For backward compatibility
      'pickUpPointInMaps': googleMapsLink, // Google Maps link
      'pickupCoordinates': latitude != null && longitude != null 
          ? "$latitude,$longitude" 
          : null,
      'coordinates': coordinatesObj, // Coordinates object {lat, lng}
      'isDefault': isDefault, // Mark default address
    };
  }

  factory PickupAddress.fromJson(Map<String, dynamic> json) {
    return PickupAddress(
      id: json['id'],
      addressName: json['addressName'] ?? 'Main Address',
      addressDetails: json['addressDetails'] ?? json['addressLine1'],
      nearbyLandmark: json['nearbyLandmark'],
      phoneNumber: json['phoneNumber'] ?? json['pickupPhone'],
      otherPhoneNumber: json['otherPhoneNumber'],
      country: json['country'],
      region: json['region'] ?? json['city'],
      zone: json['zone'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      formattedAddress: json['formattedAddress'] ?? json['pickupLocationString'],
    );
  }

  PickupAddress copyWith({
    String? id,
    String? addressName,
    String? addressDetails,
    String? nearbyLandmark,
    String? phoneNumber,
    String? otherPhoneNumber,
    String? country,
    String? region,
    String? zone,
    double? latitude,
    double? longitude,
    String? formattedAddress,
  }) {
    return PickupAddress(
      id: id ?? this.id,
      addressName: addressName ?? this.addressName,
      addressDetails: addressDetails ?? this.addressDetails,
      nearbyLandmark: nearbyLandmark ?? this.nearbyLandmark,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otherPhoneNumber: otherPhoneNumber ?? this.otherPhoneNumber,
      country: country ?? this.country,
      region: region ?? this.region,
      zone: zone ?? this.zone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      formattedAddress: formattedAddress ?? this.formattedAddress,
    );
  }
}

