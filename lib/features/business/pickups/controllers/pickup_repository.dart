import 'package:now_shipping/data/services/api_service.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import 'package:now_shipping/features/business/pickups/models/pickup_model.dart';

class PickupRepository {
  final ApiService _apiService;
  final AuthService _authService;
  
  PickupRepository({
    required ApiService apiService,
    required AuthService authService,
  }) : 
    _apiService = apiService,
    _authService = authService;

  /// Get pickups from API
  /// [pickupType] can be "Upcoming" or "Completed"
  Future<List<PickupModel>> getPickups({String pickupType = "Upcoming"}) async {
    try {
      print('DEBUG PICKUP REPO: Fetching pickups with pickupType: $pickupType');
      
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        print('DEBUG PICKUP REPO: Auth token is null');
        throw Exception('Authentication token not found');
      }
      
      // Fetch pickups from API
      final response = await _apiService.get(
        '/business/get-pickups',
        token: token,
        queryParams: {'pickupType': pickupType},
      );

      print('DEBUG PICKUP REPO: API response type: ${response.runtimeType}');
      print('DEBUG PICKUP REPO: API response: $response');
      
      // Check if response is valid
      if (response == null) {
        print('DEBUG PICKUP REPO: Response is null');
        return [];
      }
      
      // Check if response is a list (direct array response)
      if (response is List) {
        print('DEBUG PICKUP REPO: Response is a list with ${response.length} items');
        return response
            .map((pickup) => PickupModel.fromJson(pickup as Map<String, dynamic>))
            .toList();
      }
      
      // Check if response is a map with pickups array
      if (response is Map<String, dynamic>) {
        if (response.containsKey('pickups') && response['pickups'] is List) {
          final pickupsData = response['pickups'] as List;
          print('DEBUG PICKUP REPO: Found pickups array with ${pickupsData.length} items');
          return pickupsData
              .map((pickup) => PickupModel.fromJson(pickup as Map<String, dynamic>))
              .toList();
        }
        
        if (response.containsKey('data') && response['data'] is List) {
          final pickupsData = response['data'] as List;
          print('DEBUG PICKUP REPO: Found data array with ${pickupsData.length} items');
          return pickupsData
              .map((pickup) => PickupModel.fromJson(pickup as Map<String, dynamic>))
              .toList();
        }
      }
      
      print('DEBUG PICKUP REPO: Unexpected response format: $response');
      return [];
    } catch (e) {
      print('DEBUG PICKUP REPO: Exception in getPickups: $e');
      throw Exception('Failed to fetch pickups: $e');
    }
  }

  /// Get pickup details by ID
  Future<PickupModel?> getPickupDetails(String pickupId) async {
    try {
      print('DEBUG PICKUP REPO: Fetching pickup details for ID: $pickupId');
      
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        print('DEBUG PICKUP REPO: Auth token is null');
        throw Exception('Authentication token not found');
      }
      
      // Fetch pickup details from API
      final response = await _apiService.get(
        '/business/pickup-details/$pickupId',
        token: token,
      );
      
      print('DEBUG PICKUP REPO: Pickup details response type: ${response.runtimeType}');
      print('DEBUG PICKUP REPO: Pickup details response: $response');
      
      // Return the pickup details
      if (response is Map<String, dynamic>) {
        return PickupModel.fromJson(response);
      } else {
        print('DEBUG PICKUP REPO: Response is not a map: $response');
        return null;
      }
    } catch (e) {
      print('DEBUG PICKUP REPO: Exception in getPickupDetails: $e');
      throw Exception('Failed to fetch pickup details: $e');
    }
  }

  /// Get picked up orders for a specific pickup number
  Future<List<PickedUpOrder>> getPickedUpOrders(String pickupNumber) async {
    try {
      print('DEBUG PICKUP REPO: Fetching picked up orders for pickup number: $pickupNumber');
      
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        print('DEBUG PICKUP REPO: Auth token is null');
        throw Exception('Authentication token not found');
      }
      
      // Fetch picked up orders from API
      final response = await _apiService.get(
        '/business/pickup-details/$pickupNumber/get-pickedup-orders',
        token: token,
      );
      
      print('DEBUG PICKUP REPO: Picked up orders response type: ${response.runtimeType}');
      print('DEBUG PICKUP REPO: Picked up orders response: $response');
      
      // Check if response is valid
      if (response == null) {
        print('DEBUG PICKUP REPO: Response is null');
        return [];
      }
      
      // Check if response is a map with ordersPickedUp array
      if (response is Map<String, dynamic>) {
        if (response.containsKey('ordersPickedUp') && response['ordersPickedUp'] is List) {
          final ordersData = response['ordersPickedUp'] as List;
          print('DEBUG PICKUP REPO: Found ordersPickedUp array with ${ordersData.length} items');
          return ordersData
              .map((order) => PickedUpOrder.fromJson(order as Map<String, dynamic>))
              .toList();
        }
      }
      
      print('DEBUG PICKUP REPO: Unexpected response format: $response');
      return [];
    } catch (e) {
      print('DEBUG PICKUP REPO: Exception in getPickedUpOrders: $e');
      throw Exception('Failed to fetch picked up orders: $e');
    }
  }
} 