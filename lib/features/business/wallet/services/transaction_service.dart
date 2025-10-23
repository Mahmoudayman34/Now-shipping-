import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:now_shipping/data/services/api_service.dart';
import 'package:now_shipping/features/business/wallet/models/transaction_model.dart';
import 'package:now_shipping/features/business/wallet/models/wallet_model.dart';

class TransactionService {
  final ApiService _apiService;
  
  TransactionService({required ApiService apiService}) : _apiService = apiService;

  /// Get transactions by time period
  /// timePeriod: 'today', 'week', 'month', 'year', 'all'
  Future<List<TransactionModel>> getTransactions({
    String timePeriod = 'all',
    String? token,
  }) async {
    try {
      print('DEBUG TRANSACTION SERVICE: Fetching transactions with timePeriod: $timePeriod');
      
      final queryParams = <String, dynamic>{
        'timePeriod': timePeriod,
      };
      
      final response = await _apiService.get(
        '/business/transactions',
        token: token,
        queryParams: queryParams,
      );
      
      print('DEBUG TRANSACTION SERVICE: Raw API response: $response');
      
      if (response is List) {
        final transactions = response.map((json) => TransactionModel.fromJson(json)).toList();
        print('DEBUG TRANSACTION SERVICE: Parsed ${transactions.length} transactions');
        return transactions;
      } else {
        print('DEBUG TRANSACTION SERVICE: Unexpected response format: ${response.runtimeType}');
        return [];
      }
    } catch (e) {
      print('DEBUG TRANSACTION SERVICE: Error fetching transactions: $e');
      rethrow;
    }
  }

  /// Get wallet balance information
  /// This would typically be a separate endpoint, but for now we'll calculate from transactions
  Future<WalletModel> getWalletBalance({String? token}) async {
    try {
      print('DEBUG TRANSACTION SERVICE: Fetching wallet balance');
      
      // Get all transactions to calculate balance
      final transactions = await getTransactions(timePeriod: 'all', token: token);
      
      // Calculate total balance from settled transactions
      double totalBalance = 0.0;
      int unsettledCount = 0;
      
      for (final transaction in transactions) {
        if (transaction.settled) {
          totalBalance += transaction.transactionAmount;
        } else {
          unsettledCount++;
        }
      }
      
      // Mock withdrawal settings - in real implementation, this would come from user settings
      final nextWithdrawalDate = DateTime.now().add(const Duration(days: 7));
      
      final wallet = WalletModel(
        totalBalance: totalBalance,
        unsettledTransactions: unsettledCount,
        nextWithdrawalDate: nextWithdrawalDate,
        withdrawalFrequency: 'Weekly',
        lastUpdated: DateTime.now(),
      );
      
      print('DEBUG TRANSACTION SERVICE: Calculated balance: ${wallet.formattedBalance}');
      return wallet;
    } catch (e) {
      print('DEBUG TRANSACTION SERVICE: Error fetching wallet balance: $e');
      rethrow;
    }
  }

  /// Export transactions to Excel with advanced filtering
  Future<void> exportTransactions({
    String timePeriod = 'all',
    String statusFilter = 'all',
    String transactionType = 'all',
    DateTime? dateFrom,
    DateTime? dateTo,
    String? token,
  }) async {
    try {
      print('DEBUG TRANSACTION SERVICE: Exporting transactions with filters:');
      print('  - timePeriod: $timePeriod');
      print('  - statusFilter: $statusFilter');
      print('  - transactionType: $transactionType');
      print('  - dateFrom: $dateFrom');
      print('  - dateTo: $dateTo');
      print('  - token: ${token != null ? '${token.substring(0, 10)}...' : 'null'}');
      
      // Build query parameters
      final queryParams = <String, dynamic>{
        'timePeriod': timePeriod,
        'statusFilter': statusFilter,
        'transactionType': transactionType,
      };
      
      // Add custom date range if provided
      if (dateFrom != null && dateTo != null) {
        queryParams['dateFrom'] = dateFrom.toIso8601String().split('T')[0];
        queryParams['dateTo'] = dateTo.toIso8601String().split('T')[0];
      }
      
      // Call the export API endpoint with token
      final response = await _apiService.get(
        '/business/wallet/export-transactions',
        token: token,
        queryParams: queryParams,
      );
      
      print('DEBUG TRANSACTION SERVICE: Export API response received');
      
      // Handle binary file response
      if (response != null && response['type'] == 'binary') {
        print('DEBUG TRANSACTION SERVICE: Binary file received, opening directly');
        await _openFileDirectly(response);
        print('DEBUG TRANSACTION SERVICE: File opened for user to save');
      } else {
        print('DEBUG TRANSACTION SERVICE: Unexpected response format');
        throw Exception('Unexpected response format from export API');
      }
      
      print('DEBUG TRANSACTION SERVICE: Export completed successfully');
    } catch (e) {
      print('DEBUG TRANSACTION SERVICE: Error exporting transactions: $e');
      rethrow;
    }
  }

  /// Open file directly without saving to device storage
  Future<void> _openFileDirectly(Map<String, dynamic> fileData) async {
    try {
      final bytes = fileData['data'] as List<int>;
      final filename = fileData['filename'] as String? ?? 'transactions_export.xlsx';
      
      // Create a temporary file in the app's cache directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$filename');
      
      // Write the file to temporary location
      await tempFile.writeAsBytes(bytes);
      
      print('DEBUG TRANSACTION SERVICE: Temporary file created: ${tempFile.path}');
      print('DEBUG TRANSACTION SERVICE: File size: ${bytes.length} bytes');
      
      // Open the temporary file directly
      await _openFile(tempFile.path);
      
      // Clean up temporary file after a delay (in case user needs time to save)
      Future.delayed(const Duration(minutes: 5), () async {
        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
            print('DEBUG TRANSACTION SERVICE: Temporary file cleaned up');
          }
        } catch (e) {
          print('DEBUG TRANSACTION SERVICE: Error cleaning up temporary file: $e');
        }
      });
    } catch (e) {
      print('DEBUG TRANSACTION SERVICE: Error opening file directly: $e');
      rethrow;
    }
  }


  /// Open the downloaded file with the appropriate app
  Future<void> _openFile(String filePath) async {
    try {
      print('DEBUG TRANSACTION SERVICE: Attempting to open file: $filePath');
      
      final result = await OpenFile.open(filePath);
      
      if (result.type == ResultType.done) {
        print('DEBUG TRANSACTION SERVICE: File opened successfully');
      } else {
        print('DEBUG TRANSACTION SERVICE: Failed to open file: ${result.message}');
        
        // If opening fails, try to open with a specific app
        if (Platform.isAndroid) {
          // Try to open with Excel or Google Sheets
          await _tryOpenWithSpecificApp(filePath);
        }
      }
    } catch (e) {
      print('DEBUG TRANSACTION SERVICE: Error opening file: $e');
      // Don't throw error here as file opening is not critical
    }
  }

  /// Try to open file with specific apps on Android
  Future<void> _tryOpenWithSpecificApp(String filePath) async {
    try {
      // Try Microsoft Excel first
      final excelResult = await OpenFile.open(filePath, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      if (excelResult.type == ResultType.done) {
        print('DEBUG TRANSACTION SERVICE: File opened with Excel');
        return;
      }
      
      // Try Google Sheets
      final sheetsResult = await OpenFile.open(filePath, type: 'application/vnd.ms-excel');
      if (sheetsResult.type == ResultType.done) {
        print('DEBUG TRANSACTION SERVICE: File opened with Google Sheets');
        return;
      }
      
      // Try any app that can handle the file
      final anyResult = await OpenFile.open(filePath);
      if (anyResult.type == ResultType.done) {
        print('DEBUG TRANSACTION SERVICE: File opened with default app');
      } else {
        print('DEBUG TRANSACTION SERVICE: No app found to open Excel file');
      }
    } catch (e) {
      print('DEBUG TRANSACTION SERVICE: Error opening with specific app: $e');
    }
  }
}
