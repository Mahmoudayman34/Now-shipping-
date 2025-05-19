import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:now_shipping/config/env.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final bool isNeedStorage;
  final bool isCompleted;
  final bool isVerified;
  final String createdAt;
  final String profileImage;
  final BrandInfo brandInfo;
  final PickUpAddress pickUpAddress;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.isNeedStorage,
    required this.isCompleted,
    required this.isVerified,
    required this.createdAt,
    required this.profileImage,
    required this.brandInfo,
    required this.pickUpAddress,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isNeedStorage: json['isNeedStorage'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] ?? '',
      profileImage: json['profileImage'] ?? '',
      brandInfo: BrandInfo.fromJson(json['brandInfo'] ?? {}),
      pickUpAddress: PickUpAddress.fromJson(json['pickUpAdress'] ?? {}),
      role: json['role'] ?? '',
    );
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
    List<String> sellingPoints = [];
    if (json['sellingPoints'] != null) {
      sellingPoints = List<String>.from(json['sellingPoints']);
    }
    
    return BrandInfo(
      sellingPoints: sellingPoints,
      brandName: json['brandName'] ?? '',
    );
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
}

class UserService {
  final AuthService _authService;
  final String _baseUrl = AppConfig.apiBaseUrl;

  UserService(this._authService);

  Future<UserModel?> getUserData() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/business/user-data'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return UserModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Method to update user profile
  Future<bool> updateUserProfile({
    required String name,
    required String phoneNumber,
    required String brandName,
    String? profileImage,
    String? email,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'name': name,
        'phoneNumber': phoneNumber,
        'brandName': brandName,
      };

      // Add optional parameters only if they're provided
      if (profileImage != null && profileImage.isNotEmpty) {
        requestBody['profileImage'] = profileImage;
      }

      if (email != null && email.isNotEmpty) {
        requestBody['email'] = email;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/business/edit-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMessage = response.body;
        print('Error updating profile: ${response.statusCode}, $errorMessage');
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while updating profile: $e');
      return false;
    }
  }
}

// Provider for the UserService
final userServiceProvider = Provider<UserService>((ref) {
  final authService = ref.read(authServiceProvider);
  return UserService(authService);
});

// Provider for the user data
final userDataProvider = FutureProvider<UserModel?>((ref) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getUserData();
}); 