class ProfileCompletionModel {
  final String? ipaoPhoneNumber; // Required if paymentMethod = instaPay
  final String? mobileWalletNumber; // Required if paymentMethod = mobileWallet
  final String? accountName; // Required if paymentMethod = bankTransfer
  final String? accountNumber; // Required if paymentMethod = bankTransfer
  final String? iban; // Optional if paymentMethod = bankTransfer
  final String? bankName; // Required if paymentMethod = bankTransfer
  final String brandName; // Required
  final String brandType; // Required - "personal" or "company"
  final String industry; // Required
  final String monthlyOrders; // Required
  final List<String> sellingPoints; // Required (non-empty)
  final List<String>? socialLinks; // Required
  final String country; // Required
  final String city; // Required
  final String adressDetails; // Required
  final String? pickupPhone; // Optional
  final String? otherPickupPhone; // Optional
  final String? nearbyLandmark; // Optional
  final String paymentMethod; // Required - "instaPay", "mobileWallet", or "bankTransfer"
  final String? nationalId; // Required if brandType is personal
  final List<String> photosOfBrandType; // Required
  final String? taxNumber; // Required if brandType is company
  final String? zone; // Optional
  final String? pickUpPointInMaps; // Optional - Google Maps link
  final String? coordinates; // Optional - coordinates string "lat,lng"
  final Map<String, dynamic>? pickUpPointCoordinates; // Optional - coordinates object {lat, lng}
  final List<Map<String, dynamic>>? pickupAddresses; // Optional - array of pickup addresses

  ProfileCompletionModel({
    this.ipaoPhoneNumber,
    this.mobileWalletNumber,
    this.accountName,
    this.accountNumber,
    this.iban,
    this.bankName,
    required this.brandName,
    required this.brandType,
    required this.industry,
    required this.monthlyOrders,
    required this.sellingPoints,
    this.socialLinks,
    required this.country,
    required this.city,
    required this.adressDetails,
    this.pickupPhone,
    this.otherPickupPhone,
    this.nearbyLandmark,
    required this.paymentMethod,
    this.nationalId,
    required this.photosOfBrandType,
    this.taxNumber,
    this.zone,
    this.pickUpPointInMaps,
    this.coordinates,
    this.pickUpPointCoordinates,
    this.pickupAddresses,
  });

  Map<String, dynamic> toJson() {
    return {
      if (ipaoPhoneNumber != null) 'IPAorPhoneNumber': ipaoPhoneNumber,
      if (mobileWalletNumber != null) 'mobileWalletNumber': mobileWalletNumber,
      if (accountName != null) 'accountName': accountName,
      if (accountNumber != null) 'accountNumber': accountNumber,
      if (iban != null) 'IBAN': iban,
      if (bankName != null) 'bankName': bankName,
      'brandName': brandName,
      'brandType': brandType,
      'industry': industry,
      'monthlyOrders': monthlyOrders,
      'sellingPoints': sellingPoints,
      'socialLinks': socialLinks ?? [],
      'country': country,
      'city': city,
      'adressDetails': adressDetails,
      if (pickupPhone != null) 'pickupPhone': pickupPhone,
      if (otherPickupPhone != null) 'otherPickupPhone': otherPickupPhone,
      if (nearbyLandmark != null) 'nearbyLandmark': nearbyLandmark,
      'paymentMethod': paymentMethod,
      if (nationalId != null) 'nationalId': nationalId,
      'photosOfBrandType': photosOfBrandType,
      if (taxNumber != null && taxNumber!.isNotEmpty) 'taxNumber': taxNumber,
      if (zone != null) 'zone': zone,
      if (pickUpPointInMaps != null) 'pickUpPointInMaps': pickUpPointInMaps,
      if (coordinates != null) 'coordinates': coordinates,
      if (pickUpPointCoordinates != null) 'pickUpPointCoordinates': pickUpPointCoordinates,
      if (pickupAddresses != null && pickupAddresses!.isNotEmpty) 'pickupAddresses': pickupAddresses,
    };
  }

  factory ProfileCompletionModel.fromFormData(Map<String, dynamic> formData) {
    // Extract selling channels - could be stored under 'channels' or 'sellingChannels'
    List<String> sellingPoints = [];
    if (formData.containsKey('channels') && formData['channels'] != null) {
      sellingPoints = (formData['channels'] as List<dynamic>).map((e) => e.toString()).toList();
    } else if (formData.containsKey('sellingChannels') && formData['sellingChannels'] != null) {
      sellingPoints = (formData['sellingChannels'] as List<dynamic>).map((e) => e.toString()).toList();
    }

    // Extract social links
    List<String> socialLinks = [];
    if (formData.containsKey('channelLinks') && formData['channelLinks'] is Map) {
      // If channelLinks is stored as a map, extract values
      final Map<String, dynamic> channelLinksMap = formData['channelLinks'] as Map<String, dynamic>;
      socialLinks = channelLinksMap.values.where((v) => v != null && v.toString().isNotEmpty).map((v) => v.toString()).toList();
    } else if (formData.containsKey('socialLinks') && formData['socialLinks'] != null) {
      socialLinks = (formData['socialLinks'] as List<dynamic>).map((e) => e.toString()).toList();
    }

    // Get document photos
    List<String> documentPhotos = [];
    if (formData.containsKey('documentPhotos') && formData['documentPhotos'] != null) {
      documentPhotos = (formData['documentPhotos'] as List<dynamic>).map((e) => e.toString()).toList();
    } else if (formData.containsKey('uploadedDocuments') && formData['uploadedDocuments'] != null) {
      documentPhotos = (formData['uploadedDocuments'] as List<dynamic>).map((e) => e.toString()).toList();
    }

    // Get address details - could be under addressDetails or addressLine1
    String addressDetails = '';
    if (formData.containsKey('addressDetails') && formData['addressDetails'] != null) {
      addressDetails = formData['addressDetails'] as String;
    } else if (formData.containsKey('addressLine1') && formData['addressLine1'] != null) {
      addressDetails = formData['addressLine1'] as String;
    }

    // Get monthly orders from volume or monthlyOrders field
    String monthlyOrders = '';
    if (formData.containsKey('monthlyOrders') && formData['monthlyOrders'] != null) {
      monthlyOrders = formData['monthlyOrders'] as String;
    } else if (formData.containsKey('volume') && formData['volume'] != null) {
      monthlyOrders = formData['volume'] as String;
    }
    
    // Normalize brandType value to match API requirements
    String brandType = formData['brandType'] ?? 'personal';
    if (brandType == 'individual') {
      brandType = 'personal';
    }
    
    // Normalize payment method to match API requirements
    String paymentMethod = formData['paymentMethod'] ?? 'instaPay';
    // Normalize payment method names to exactly what the server expects
    if (paymentMethod.toLowerCase() == 'instapay') {
      paymentMethod = 'instaPay'; // Ensure correct capitalization
    } else if (paymentMethod.toLowerCase() == 'wallet') {
      paymentMethod = 'mobileWallet'; // Convert to expected API value
    } else if (paymentMethod.toLowerCase() == 'bank') {
      paymentMethod = 'bankTransfer'; // Convert to expected API value
    }

    // Get first address data for backward compatibility
    final firstAddress = formData.containsKey('pickupAddresses') && formData['pickupAddresses'] is List && (formData['pickupAddresses'] as List).isNotEmpty
        ? (formData['pickupAddresses'] as List).first
        : null;
    
    // Extract coordinates for main address
    double? mainLat = formData['latitude']?.toDouble();
    double? mainLng = formData['longitude']?.toDouble();
    if (mainLat == null && firstAddress != null && firstAddress['latitude'] != null) {
      mainLat = firstAddress['latitude']?.toDouble();
      mainLng = firstAddress['longitude']?.toDouble();
    }
    
    // Generate Google Maps link if coordinates exist
    String? googleMapsLink;
    if (mainLat != null && mainLng != null) {
      googleMapsLink = 'https://www.google.com/maps?q=$mainLat,$mainLng';
    } else if (formData['pickupLocationString'] != null) {
      googleMapsLink = formData['pickupLocationString'] as String;
    } else if (formData['formattedAddress'] != null) {
      googleMapsLink = formData['formattedAddress'] as String;
    }
    
    // Build coordinates object
    Map<String, dynamic>? coordinatesObj;
    if (mainLat != null && mainLng != null) {
      coordinatesObj = {
        'lat': mainLat,
        'lng': mainLng,
      };
    }
    
    // Process pickup addresses array
    List<Map<String, dynamic>>? pickupAddressesList;
    if (formData.containsKey('pickupAddresses') && formData['pickupAddresses'] is List) {
      final addresses = formData['pickupAddresses'] as List;
      pickupAddressesList = addresses.map((addr) {
        if (addr is Map<String, dynamic>) {
          // Convert PickupAddress to API format
          return _convertPickupAddressToApiFormat(addr);
        }
        return addr as Map<String, dynamic>;
      }).toList();
    }
    
    // Get other pickup phone
    String? otherPickupPhone = formData['otherPhoneNumber'] ?? formData['otherPickupPhone'];
    if (otherPickupPhone == null && firstAddress != null) {
      otherPickupPhone = firstAddress['otherPhoneNumber'] ?? firstAddress['otherPickupPhone'];
    }

    return ProfileCompletionModel(
      ipaoPhoneNumber: formData['ipaAddress'],
      mobileWalletNumber: formData['mobileNumber'],
      accountName: formData['accountName'],
      accountNumber: formData['accountNumber'],
      iban: formData['iban'],
      bankName: formData['bankName'],
      brandName: formData['brandName'] ?? '',
      brandType: brandType,
      industry: formData['industry'] ?? '',
      monthlyOrders: monthlyOrders,
      sellingPoints: sellingPoints,
      socialLinks: socialLinks,
      country: formData['country'] ?? firstAddress?['country'] ?? '',
      city: formData['city'] ?? formData['region'] ?? firstAddress?['region'] ?? firstAddress?['city'] ?? '',
      adressDetails: addressDetails.isNotEmpty ? addressDetails : (firstAddress?['addressDetails'] ?? firstAddress?['adressDetails'] ?? ''),
      pickupPhone: formData['phoneNumber'] ?? formData['pickupPhone'] ?? firstAddress?['phoneNumber'] ?? firstAddress?['pickupPhone'],
      otherPickupPhone: otherPickupPhone,
      nearbyLandmark: formData['nearbyLandmark'] ?? firstAddress?['nearbyLandmark'],
      paymentMethod: paymentMethod,
      nationalId: formData['nationalIdNumber'],
      photosOfBrandType: documentPhotos,
      taxNumber: formData['taxNumber'],
      zone: formData['zone'] ?? firstAddress?['zone'],
      pickUpPointInMaps: googleMapsLink,
      coordinates: _formatCoordinates(mainLat, mainLng) ?? formData['pickupCoordinates'],
      pickUpPointCoordinates: coordinatesObj,
      pickupAddresses: pickupAddressesList,
    );
  }
  
  static String? _formatCoordinates(dynamic lat, dynamic lng) {
    if (lat != null && lng != null) {
      return '$lat,$lng';
    }
    return null;
  }
  
  /// Convert PickupAddress from form data to API format
  static Map<String, dynamic> _convertPickupAddressToApiFormat(Map<String, dynamic> addr) {
    final double? lat = addr['latitude']?.toDouble();
    final double? lng = addr['longitude']?.toDouble();
    
    // Generate Google Maps link
    String? googleMapsLink;
    if (lat != null && lng != null) {
      googleMapsLink = 'https://www.google.com/maps?q=$lat,$lng';
    } else if (addr['formattedAddress'] != null) {
      googleMapsLink = addr['formattedAddress'] as String;
    } else if (addr['pickupLocationString'] != null) {
      googleMapsLink = addr['pickupLocationString'] as String;
    }
    
    // Build coordinates object
    Map<String, dynamic>? coordinatesObj;
    if (lat != null && lng != null) {
      coordinatesObj = {
        'lat': lat,
        'lng': lng,
      };
    }
    
    return {
      'addressName': addr['addressName'] ?? 'Main Address',
      'isDefault': addr['isDefault'] ?? (addr['addressName'] == 'Main Address' || addr['addressName'] == null),
      'country': addr['country'] ?? 'Egypt',
      'city': addr['city'] ?? addr['region'] ?? 'Cairo',
      'zone': addr['zone'],
      'adressDetails': addr['adressDetails'] ?? addr['addressDetails'],
      'nearbyLandmark': addr['nearbyLandmark'],
      'pickupPhone': addr['pickupPhone'] ?? addr['phoneNumber'],
      'otherPickupPhone': addr['otherPickupPhone'] ?? addr['otherPhoneNumber'],
      'pickUpPointInMaps': googleMapsLink,
      if (coordinatesObj != null) 'coordinates': coordinatesObj,
    };
  }
}