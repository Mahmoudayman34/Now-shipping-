import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:now_shipping/data/services/api_service.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import 'package:now_shipping/features/business/pickups/controllers/pickup_repository.dart';
import 'package:now_shipping/features/business/pickups/models/pickup_model.dart';

// Provider for the pickup repository
final pickupRepositoryProvider = Provider<PickupRepository>((ref) {
  final apiService = ApiService();
  final authService = ref.watch(authServiceProvider);
  return PickupRepository(
    apiService: apiService,
    authService: authService,
  );
});

// Provider for selected pickup type
final selectedPickupTypeProvider = StateProvider<String>((ref) => 'Upcoming');

// Provider for pickups data
final pickupsProvider = FutureProvider.family<List<PickupModel>, String>((ref, pickupType) async {
  final repository = ref.read(pickupRepositoryProvider);
  return repository.getPickups(pickupType: pickupType);
});

// Provider for pickup details
final pickupDetailsProvider = FutureProvider.family<PickupModel?, String>((ref, pickupId) async {
  final repository = ref.read(pickupRepositoryProvider);
  return repository.getPickupDetails(pickupId);
});

// Provider for upcoming pickups
final upcomingPickupsProvider = FutureProvider<List<PickupModel>>((ref) async {
  final repository = ref.read(pickupRepositoryProvider);
  return repository.getPickups(pickupType: 'Upcoming');
});

// Provider for completed pickups
final completedPickupsProvider = FutureProvider<List<PickupModel>>((ref) async {
  final repository = ref.read(pickupRepositoryProvider);
  return repository.getPickups(pickupType: 'Completed');
});

// Provider for picked up orders
final pickedUpOrdersProvider = FutureProvider.family<List<PickedUpOrder>, String>((ref, pickupNumber) async {
  final repository = ref.read(pickupRepositoryProvider);
  return repository.getPickedUpOrders(pickupNumber);
});

// Provider for refresh trigger
final pickupRefreshProvider = StateProvider<int>((ref) => 0);

// Method to refresh pickups data
void refreshPickups(WidgetRef ref) {
  ref.invalidate(upcomingPickupsProvider);
  ref.invalidate(completedPickupsProvider);
  ref.read(pickupRefreshProvider.notifier).state++;
} 