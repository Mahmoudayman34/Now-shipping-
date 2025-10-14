import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/env.dart';
import '../../../data/services/api_service.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final bool isEmailVerified;
  final bool isProfileComplete;
  final String? role;
  final bool isNeedStorage;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    this.isEmailVerified = false,
    this.isProfileComplete = false,
    this.role,
    this.isNeedStorage = false,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    bool? isEmailVerified,
    bool? isProfileComplete,
    String? role,
    bool? isNeedStorage,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      role: role ?? this.role,
      isNeedStorage: isNeedStorage ?? this.isNeedStorage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'isEmailVerified': isEmailVerified,
      'isProfileComplete': isProfileComplete,
      'role': role,
      'isNeedStorage': isNeedStorage,
    };
  }

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String? ?? '',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      role: json['role'] as String?,
      isNeedStorage: json['isNeedStorage'] as bool? ?? false,
    );
  }
}

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // API endpoint
  final String _baseUrl = AppConfig.apiBaseUrl;
  final http.Client _client = http.Client();

  // Login user
  Future<UserModel?> login({required String email, required String password}) async {
    try {
      final uri = Uri.parse('$_baseUrl/auth/login');
      
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['status'] == 'success') {
          // Save token and user data
          final token = jsonData['token'] as String;
          final userData = jsonData['user'] as Map<String, dynamic>;
          
          // Save to shared preferences
          await _saveAuthData(token, userData);
          
          // Create UserModel from response
          final userModel = UserModel(
            id: userData['id'] as String,
            email: userData['email'] as String,
            fullName: userData['name'] as String,
            phone: '', // Phone may come from profile details
            // isEmailVerified: true,
            isProfileComplete: userData['isCompleted'] as bool,
            role: userData['role'] as String,
          );
          
          return userModel;
        }
      }
      
      // Return null if login failed
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Save token and user data
  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(userData));
    await prefs.setString(_userIdKey, userData['id'] as String);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await getToken();
      
      // Try to get fresh user data if we have a token
      if (token != null) {
        try {
          // Use API service instead of direct HTTP call
          final apiClient = http.Client();
          final apiService = ApiService(client: apiClient);
          
          // Get fresh dashboard data which includes user info
          final response = await apiService.get(
            '/business/dashboard',
            token: token,
          );
          
          // Check if we got valid user data
          if (response != null && 
              response['status'] == 'success' && 
              response['userDate'] != null) {
            
            final userDate = response['userDate'];
            
            // Create updated user model
            final updatedUser = UserModel(
              id: userDate['_id']?.toString() ?? '',
              email: userDate['email']?.toString() ?? '',
              fullName: userDate['name']?.toString() ?? '',
              phone: userDate['phoneNumber']?.toString() ?? '',
              isEmailVerified: userDate['isVerified'] as bool? ?? false,
              isProfileComplete: userDate['isCompleted'] as bool? ?? false,
              role: userDate['role']?.toString(),
              isNeedStorage: userDate['isNeedStorage'] as bool? ?? false,
            );
            
            // Update the stored user data
            await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
            
            return updatedUser;
          }
        } catch (e) {
          print('Error fetching fresh user data: $e');
          // Continue to fallback if fetch fails
        }
      }
      
      // Fallback to cached user data
      final userData = prefs.getString(_userKey);
      if (userData != null) {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        
        return UserModel(
          id: userMap['id']?.toString() ?? '',
          email: userMap['email']?.toString() ?? '',
          fullName: userMap['name']?.toString() ?? userMap['fullName']?.toString() ?? '',
          phone: userMap['phone']?.toString() ?? '',
          isEmailVerified: userMap['isEmailVerified'] as bool? ?? false,
          isProfileComplete: userMap['isCompleted'] as bool? ?? userMap['isProfileComplete'] as bool? ?? false,
          role: userMap['role']?.toString(),
          isNeedStorage: userMap['isNeedStorage'] as bool? ?? false,
        );
      }
      
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Update user profile completion status
  Future<UserModel> completeProfile(UserModel user) async {
    // In a real app, you'd update the user data in the backend
    // For this implementation, we'll update the local model and store it
    final updatedUser = user.copyWith(isProfileComplete: true);
    
    // Store the updated user in shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
    
    return updatedUser;
  }

  // Get auth token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_userIdKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Send OTP to phone number
  Future<String?> sendOtp(String phoneNumber) async {
    try {
      final uri = Uri.parse('$_baseUrl/auth/send-otp');
      
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['message'] as String?;
      }
      
      return null;
    } catch (e) {
      print('Send OTP error: $e');
      return null;
    }
  }

  // Sign up new user
  Future<Map<String, dynamic>> signup({
    required String email,
    required String fullName,
    required String password,
    required String phoneNumber,
    bool storageCheck = false,
    required bool termsCheck,
    required String otp,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/auth/signup');
      
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'fullName': fullName,
          'password': password,
          'phoneNumber': phoneNumber,
          'storageCheck': storageCheck ? "true" : "false",
          'termsCheck': termsCheck,
          'otp': otp,
        }),
      ); 
      final jsonData = jsonDecode(response.body);
      return {
        'status': jsonData['status'],
        'message': jsonData['message'] ?? 'Unknown error occurred',
      };
    } catch (e) {
      print('Signup error: $e');
      return {
        'status': 'error',
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Forgot password - send reset email
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final uri = Uri.parse('$_baseUrl/auth/forgot-password');
      
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );
      
      final jsonData = jsonDecode(response.body);
      return {
        'status': jsonData['status'] ?? (response.statusCode == 200 ? 'success' : 'error'),
        'message': jsonData['message'] ?? (response.statusCode == 200 ? 'Password reset email sent successfully' : 'Failed to send reset email'),
      };
    } catch (e) {
      print('Forgot password error: $e');
      return {
        'status': 'error',
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Verify OTP for forgot password
  Future<Map<String, dynamic>> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/auth/verify-forgot-password-otp');
      
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );
      
      final jsonData = jsonDecode(response.body);
      return {
        'status': jsonData['status'] ?? (response.statusCode == 200 ? 'success' : 'error'),
        'message': jsonData['message'] ?? (response.statusCode == 200 ? 'OTP verified successfully' : 'Invalid OTP'),
        'token': jsonData['token'], // Reset token for password reset
      };
    } catch (e) {
      print('Verify forgot password OTP error: $e');
      return {
        'status': 'error',
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Reset password with token
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/auth/reset-password');
      
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'password': newPassword,
        }),
      );
      
      final jsonData = jsonDecode(response.body);
      return {
        'status': jsonData['status'] ?? (response.statusCode == 200 ? 'success' : 'error'),
        'message': jsonData['message'] ?? (response.statusCode == 200 ? 'Password reset successfully' : 'Failed to reset password'),
      };
    } catch (e) {
      print('Reset password error: $e');
      return {
        'status': 'error',
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}

// Provider for auth service
final authServiceProvider = Provider((ref) => AuthService());

// Provider for current user
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});