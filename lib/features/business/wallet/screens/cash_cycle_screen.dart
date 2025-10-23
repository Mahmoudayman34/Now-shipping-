import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:now_shipping/features/business/wallet/providers/cash_cycle_provider.dart';
import 'package:now_shipping/features/business/wallet/models/cash_cycle_model.dart';

class CashCycleScreen extends ConsumerWidget {
  const CashCycleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTimePeriod = ref.watch(selectedTimePeriodProvider);
    final cashCycleAsync = ref.watch(cashCycleDataProvider(selectedTimePeriod));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: cashCycleAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error, ref, selectedTimePeriod),
        data: (cashCycleData) => _buildContent(context, ref, cashCycleData, selectedTimePeriod),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
        leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF475569),
            size: 18,
          ),
        ),
          onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Cash Cycle',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
          CircularProgressIndicator(
            color: Color(0xFFF97316),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading financial data...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a moment for large datasets',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildErrorState(dynamic error, WidgetRef ref, String selectedTimePeriod) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to Load Data',
                style: TextStyle(
                fontSize: 20,
                  fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              ),
              const SizedBox(height: 8),
              Text(
              'We encountered an issue while fetching your financial data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(cashCycleDataProvider(selectedTimePeriod)),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic cashCycleData, String selectedTimePeriod) {
    return SingleChildScrollView(
          child: Column(
            children: [
          // Hero Section
          _buildHeroSection(cashCycleData),
          
          // Time Period Selector
              _buildTimePeriodSelector(ref),
          
          // Statistics Cards
          _buildStatisticsSection(cashCycleData),
          
          // Transaction History Section
          _buildTransactionHistorySection(context, ref, selectedTimePeriod, cashCycleData),
        ],
      ),
    );
  }

  Widget _buildHeroSection(dynamic cashCycleData) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF97316),
            Color(0xFFEA580C),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
              'Financial Overview',
                  style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your earnings and manage your cash flow',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                  child: _buildHeroStatCard(
                    'Net Earnings',
                    cashCycleData.formattedNetTotal,
                    Icons.trending_up_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                  Expanded(
                  child: _buildHeroStatCard(
                    'Total Orders',
                    '${cashCycleData.completedOrdersCount + cashCycleData.returnedOrdersCount + cashCycleData.canceledOrdersCount + cashCycleData.returnCompletedOrdersCount}',
                    Icons.shopping_bag_rounded,
                    const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodSelector(WidgetRef ref) {
    final selectedTimePeriod = ref.watch(selectedTimePeriodProvider);
    final availablePeriods = ref.watch(availableTimePeriodsProvider);
    final displayNames = ref.watch(timePeriodDisplayNamesProvider);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Time Period',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: availablePeriods.asMap().entries.map((entry) {
                  final index = entry.key;
                  final period = entry.value;
                  final isSelected = selectedTimePeriod == period;
                  
                  return Padding(
                  padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => ref.read(selectedTimePeriodProvider.notifier).state = period,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF97316) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                          color: isSelected ? const Color(0xFFF97316) : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        ),
                        child: Text(
                          displayNames[index],
                          style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                        ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(dynamic cashCycleData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Income',
                  cashCycleData.formattedTotalIncome,
                  Icons.arrow_upward_rounded,
                  const Color(0xFF10B981),
                  const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Fees',
                  cashCycleData.formattedTotalFees,
                  Icons.arrow_downward_rounded,
                  const Color(0xFFEF4444),
                  const Color(0xFFFEF2F2),
                ),
            ),
          ],
        ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistorySection(BuildContext context, WidgetRef ref, String selectedTimePeriod, dynamic cashCycleData) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Detailed view of all your order earnings and fees',
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _exportToExcel(ref, selectedTimePeriod, context),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...cashCycleData.orders.map((order) => _buildOrderCard(order)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(CashCycleOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - More compact
            Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                  order.formattedOrderNumber,
                style: const TextStyle(
                fontWeight: FontWeight.bold,
                          color: Color(0xFFF97316),
                fontSize: 16,
                ),
              ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.statusDisplay,
                    style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.orderStatus),
                ),
                ),
              ),
                          const SizedBox(width: 8),
              Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                              color: const Color(0xFFF97316).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                              order.orderShipping.orderType,
                style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: Color(0xFFF97316),
                ),
                            ),
                          ),
                        ],
                      ),
                    ],
                ),
              ),
              ],
            ),
          ),
          // Details - More compact layout
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildCompactDetails(order),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetails(CashCycleOrder order) {
    return Column(
      children: [
        // First row - Order Date and Order Value
        Row(
              children: [
            Expanded(
              child: _buildCompactDetailItem("Order Date", order.formattedOrderDate, Icons.calendar_today_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactDetailItem("Order Value", order.formattedOrderValue, Icons.attach_money_rounded),
            ),
          ],
        ),
                const SizedBox(height: 8),
        // Second row - Service Fee and Payment Date
        Row(
          children: [
            Expanded(
              child: _buildCompactDetailItem("Service Fee", '${order.formattedOrderFees} ${_getFeeDescription(order)}', Icons.receipt_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactDetailItem("Payment Date", _formatPaymentReleaseDate(order), Icons.payment_rounded),
            ),
          ],
        ),
                const SizedBox(height: 8),
        // Delivery Location - Full width
        _buildCompactDetailItem("Delivery Location", order.orderCustomer.displayLocation, Icons.location_on_rounded),
      ],
    );
  }

  Widget _buildCompactDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'canceled':
        return const Color(0xFFEF4444);
      case 'returned':
        return const Color(0xFFF59E0B);
      case 'returnCompleted':
        return const Color(0xFFF97316);
      case 'inProgress':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getFeeDescription(CashCycleOrder order) {
    switch (order.orderStatus) {
      case 'canceled':
        return 'Cancellation Fees';
      case 'returned':
        return 'Return Fees';
      case 'returnCompleted':
        return 'Return Completed Fees';
      default:
        return 'Platform Fee';
    }
  }

  String _formatPaymentReleaseDate(CashCycleOrder order) {
    if (order.moneyReleaseDate == null) {
      return 'Payment Pending';
    }
    
    final date = order.moneyReleaseDate!;
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    
    return '$weekday, $month $day, $year';
  }

  Future<void> _exportToExcel(WidgetRef ref, String timePeriod, BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF97316),
          ),
        ),
      );

      final result = await ref.read(exportCashCycleProvider(timePeriod).future);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (result != null && result['type'] == 'binary') {
        // Handle the Excel file download
        await _handleExcelDownload(result, context);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Excel file opened for saving'),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        throw Exception('Invalid export response');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Export failed: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleExcelDownload(Map<String, dynamic> result, BuildContext context) async {
    try {
      // Get the binary data
      final binaryData = result['data'] as List<int>;
      final filename = result['filename'] as String? ?? 'cash_cycles_export.xlsx';
      
      // Get temporary directory for the file
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$filename';
      final file = File(filePath);
      
      // Write the binary data to the temporary file
      await file.writeAsBytes(binaryData);
      
      print('Excel file created: $filePath (${binaryData.length} bytes)');
      
      // Open the file directly for the user to save
      await _openExcelFile(filePath);
      
    } catch (e) {
      throw Exception('Failed to prepare Excel file: $e');
    }
  }


  Future<void> _openExcelFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        print('Could not open file: ${result.message}');
        // The file will be opened in the default app (Excel, Google Sheets, etc.)
        // where the user can save it to their preferred location
      }
    } catch (e) {
      print('Error opening file: $e');
    }
  }

}