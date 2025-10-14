import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/data/services/api_service.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';
import '../../../../core/l10n/app_localizations.dart';

// Provider for delivery fee calculation service
final deliveryFeeServiceProvider = Provider<DeliveryFeeService>((ref) {
  final apiService = ref.watch(Provider<ApiService>((ref) => ApiService()));
  final authService = ref.watch(Provider<AuthService>((ref) => AuthService()));
  return DeliveryFeeService(apiService: apiService, authService: authService);
});

// Provider for delivery fee calculation that updates when parameters change
final deliveryFeeProvider = FutureProvider.autoDispose<double>((ref) async {
  // Watch for changes in the order model
  final orderModel = ref.watch(orderModelProvider);
  
  // Extract parameters needed for fee calculation
  final government = orderModel.customerAddress?.split(',').first.trim();
  final orderType = orderModel.deliveryType;
  
  // Get express shipping value from order model
  final isExpressShipping = orderModel.expressShipping ?? false;
  
  // Skip calculation if we don't have required parameters
  if (government == null || government.isEmpty || orderType == null || orderType.isEmpty) {
    return 0.0;
  }
  
  // Log the parameters being used for calculation
  print('DEBUG FEE: Calculating fees with government: $government, orderType: $orderType, express: $isExpressShipping');
  
  try {
    // Get delivery fee service and calculate fee
    final feeService = ref.read(deliveryFeeServiceProvider);
    final fee = await feeService.calculateDeliveryFee(
      government: government,
      orderType: orderType,
      isExpressShipping: isExpressShipping,
    );
    
    print('DEBUG FEE: Successfully calculated fee from API: $fee EGP');
    return fee;
  } catch (e) {
    print('DEBUG FEE: Error calculating fee: $e');
    return 0.0;
  }
});

// Service class for delivery fee calculation
class DeliveryFeeService {
  final ApiService _apiService;
  final AuthService _authService;
  
  DeliveryFeeService({
    required ApiService apiService,
    required AuthService authService,
  }) : 
    _apiService = apiService,
    _authService = authService;
    
  Future<double> calculateDeliveryFee({
    required String government,
    required String orderType,
    required bool isExpressShipping,
  }) async {
    try {
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      // Prepare request body
      final requestBody = {
        'government': government,
        'orderType': orderType,
        'isExpressShipping': isExpressShipping,
      };
      
      print('DEBUG FEE: Sending API request with body: $requestBody');
      
      // Make API call
      final response = await _apiService.post(
        '/business/calculate-fees',
        token: token,
        body: requestBody,
      );
      
      // Extract fee from response
      if (response is Map<String, dynamic>) {
        print('DEBUG FEE: Response received: $response');
        if (response.containsKey('fee')) {
          final fee = (response['fee'] as num).toDouble();
          print('DEBUG FEE: Found fee in response: $fee');
          return fee;
        } else if (response.containsKey('fees')) {
          return (response['fees'] as num).toDouble();
        } else if (response.containsKey('deliveryFee')) {
          return (response['deliveryFee'] as num).toDouble();
        } else {
          print('DEBUG FEE: Fee key not found in response: $response');
          return 0.0;
        }
      } else {
        print('DEBUG FEE: Unexpected response format: $response');
        return 0.0;
      }
    } catch (e) {
      print('DEBUG FEE: Error in calculateDeliveryFee: $e');
      return 0.0;
    }
  }
}

class DeliveryFeeSummaryWidget extends ConsumerWidget {
  const DeliveryFeeSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryFeeAsync = ref.watch(deliveryFeeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          AppLocalizations.of(context).deliveryFeeSummary,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xff2F2F2F),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Orange highlighted container with fee information
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5E6), // Light orange background color
            borderRadius: BorderRadius.circular(12),
          ),
          child: deliveryFeeAsync.when(
            data: (deliveryFee) => _buildFeeDisplay(context, deliveryFee),
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
            error: (error, stack) => _buildErrorState(error),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeeDisplay(BuildContext context, double deliveryFee) {
    return Column(
      children: [
        // Fee amount
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              deliveryFee.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'EGP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Total delivery fee text
        Text(
          AppLocalizations.of(context).totalDeliveryFee,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.orange.shade700,
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorState(Object error) {
    return Column(
      children: [
        Icon(
          Icons.error_outline, 
          color: Colors.orange.shade700,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Unable to calculate fee',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.orange.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}