class ProfileCompletionModel {
  final String? ipaoPhoneNumber; // Required if paymentMethod = instaPay
  final String? mobileWalletNumber; // Required if paymentMethod = mobileWallet
  final String? accountName; // Required if paymentMethod = bankTransfer
  final String? iban; // Required if paymentMethod = bankTransfer
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
  final String? nearbyLandmark; // Optional
  final String paymentMethod; // Required - "instaPay", "mobileWallet", or "bankTransfer"
  final String? nationalId; // Required if brandType is personal
  final List<String> photosOfBrandType; // Required
  final String? taxNumber; // Required if brandType is company
  final String? zone; // Optional
  final String? pickUpPointInMaps; // Optional - points
  final String? coordinates; // Optional - coordinates

  ProfileCompletionModel({
    this.ipaoPhoneNumber,
    this.mobileWalletNumber,
    this.accountName,
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
    this.nearbyLandmark,
    required this.paymentMethod,
    this.nationalId,
    required this.photosOfBrandType,
    this.taxNumber,
    this.zone,
    this.pickUpPointInMaps,
    this.coordinates,
  });

  Map<String, dynamic> toJson() {
    return {
      if (ipaoPhoneNumber != null) 'IPAorPhoneNumber': ipaoPhoneNumber,
      if (mobileWalletNumber != null) 'mobileWalletNumber': mobileWalletNumber,
      if (accountName != null) 'accountName': accountName,
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
      if (nearbyLandmark != null) 'nearbyLandmark': nearbyLandmark,
      'paymentMethod': paymentMethod,
      if (nationalId != null) 'nationalId': nationalId,
      'photosOfBrandType': photosOfBrandType,
      if (taxNumber != null) 'taxNumber': taxNumber,
      if (zone != null) 'zone': zone,
      if (pickUpPointInMaps != null) 'pickUpPointInMaps': pickUpPointInMaps,
      if (coordinates != null) 'coordinates': coordinates,
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

    return ProfileCompletionModel(
      ipaoPhoneNumber: formData['ipaAddress'],
      mobileWalletNumber: formData['mobileNumber'],
      accountName: formData['accountName'],
      iban: formData['iban'],
      bankName: formData['bankName'],
      brandName: formData['brandName'] ?? '',
      brandType: brandType,
      industry: formData['industry'] ?? '',
      monthlyOrders: monthlyOrders,
      sellingPoints: sellingPoints,
      socialLinks: socialLinks,
      country: formData['country'] ?? '',
      city: formData['city'] ?? formData['region'] ?? '',
      adressDetails: addressDetails,
      pickupPhone: formData['phoneNumber'] ?? formData['pickupPhone'],
      nearbyLandmark: formData['nearbyLandmark'],
      paymentMethod: paymentMethod,
      nationalId: formData['nationalIdNumber'],
      photosOfBrandType: documentPhotos,
      taxNumber: formData['taxNumber'],
      zone: formData['zone'],
      pickUpPointInMaps: formData['pickupLocationString'] ?? formData['formattedAddress'],
      coordinates: _formatCoordinates(formData['latitude'], formData['longitude']) ?? formData['pickupCoordinates'],
    );
  }
  
  static String? _formatCoordinates(dynamic lat, dynamic lng) {
    if (lat != null && lng != null) {
      return '$lat,$lng';
    }
    return null;
  }
}