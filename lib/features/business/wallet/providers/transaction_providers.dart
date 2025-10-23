import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:now_shipping/data/services/api_service.dart';
import 'package:now_shipping/features/business/wallet/models/transaction_model.dart';
import 'package:now_shipping/features/business/wallet/models/wallet_model.dart';
import 'package:now_shipping/features/business/wallet/services/transaction_service.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';

// Transaction service provider
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final apiService = ApiService();
  return TransactionService(apiService: apiService);
});

// Transaction list provider
final transactionsProvider = FutureProvider.family<List<TransactionModel>, String>((ref, timePeriod) async {
  final transactionService = ref.watch(transactionServiceProvider);
  final authService = ref.watch(authServiceProvider);
  
  final token = await authService.getToken();
  if (token == null) {
    throw Exception('No authentication token');
  }
  
  return await transactionService.getTransactions(
    timePeriod: timePeriod,
    token: token,
  );
});

// Wallet balance provider
final walletBalanceProvider = FutureProvider<WalletModel>((ref) async {
  final transactionService = ref.watch(transactionServiceProvider);
  final authService = ref.watch(authServiceProvider);
  
  final token = await authService.getToken();
  if (token == null) {
    throw Exception('No authentication token');
  }
  
  return await transactionService.getWalletBalance(token: token);
});

// Selected time period provider
final selectedTimePeriodProvider = StateProvider<String>((ref) => 'month');

// Selected status filter provider
final selectedStatusFilterProvider = StateProvider<String>((ref) => 'All Status');

// Selected type filter provider
final selectedTypeFilterProvider = StateProvider<String>((ref) => 'All Types');

