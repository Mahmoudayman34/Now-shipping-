import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:now_shipping/features/business/wallet/providers/cash_cycle_provider.dart';
import 'package:now_shipping/features/business/wallet/models/cash_cycle_model.dart';
import 'package:now_shipping/core/services/permission_service.dart';
import 'package:now_shipping/core/l10n/app_localizations.dart';

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
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(error, ref, selectedTimePeriod, context),
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
      title: Text(
        AppLocalizations.of(context).cashCycleTitle,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
          CircularProgressIndicator(
            color: Color(0xFFF97316),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).loadingFinancialData,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).loadingLargeDatasetNote,
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildErrorState(dynamic error, WidgetRef ref, String selectedTimePeriod, BuildContext context) {
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
            Text(
              AppLocalizations.of(context).unableToLoadData,
                style: TextStyle(
                fontSize: 20,
                  fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              ),
              const SizedBox(height: 8),
              Text(
              AppLocalizations.of(context).fetchFinancialDataIssue,
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
              label: Text(AppLocalizations.of(context).tryAgain),
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
          _buildHeroSection(context, cashCycleData),
          
          // Time Period Selector
              _buildTimePeriodSelector(context, ref),
          
          // Statistics Cards
          _buildStatisticsSection(context, cashCycleData),
          
          // Transaction History Section
          _buildTransactionHistorySection(context, ref, selectedTimePeriod, cashCycleData),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, dynamic cashCycleData) {
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
                Text(
              AppLocalizations.of(context).financialOverview,
                  style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).trackEarnings,
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
                    AppLocalizations.of(context).netEarnings,
                    cashCycleData.formattedNetTotal,
                    Icons.trending_up_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                  Expanded(
                  child: _buildHeroStatCard(
                    AppLocalizations.of(context).totalOrders,
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

  Widget _buildTimePeriodSelector(BuildContext context, WidgetRef ref) {
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
          Text(
            AppLocalizations.of(context).timePeriod,
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
                          _localizedPeriodLabel(context, period, displayNames[index]),
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

  Widget _buildStatisticsSection(BuildContext context, dynamic cashCycleData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context).totalIncome,
                  cashCycleData.formattedTotalIncome,
                  Icons.arrow_upward_rounded,
                  const Color(0xFF10B981),
                  const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context).totalFees,
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
                          Text(
                            AppLocalizations.of(context).transactionHistory,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context).transactionHistoryDetailed,
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
                      label: Text(AppLocalizations.of(context).export),
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
                ...cashCycleData.orders.map((order) => _buildOrderCard(context, order)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, CashCycleOrder order) {
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
                    _localizeOrderStatus(context, order.statusDisplay),
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
                              _localizeOrderType(context, order.orderShipping.orderType),
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
            child: _buildCompactDetails(context, order),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetails(BuildContext context, CashCycleOrder order) {
    return Column(
      children: [
        // First row - Order Date and Order Value
        Row(
              children: [
            Expanded(
              child: _buildCompactDetailItem(AppLocalizations.of(context).orderDate, order.formattedOrderDate, Icons.calendar_today_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactDetailItem(AppLocalizations.of(context).orderValue, order.formattedOrderValue, Icons.attach_money_rounded),
            ),
          ],
        ),
                const SizedBox(height: 8),
        // Second row - Service Fee and Payment Date
        Row(
          children: [
            Expanded(
              child: _buildCompactDetailItem(AppLocalizations.of(context).serviceFee, '${order.formattedOrderFees} ${_getFeeDescriptionLocalized(context, order)}', Icons.receipt_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactDetailItem(AppLocalizations.of(context).paymentDate, _formatPaymentReleaseDateLocalized(context, order), Icons.payment_rounded),
            ),
          ],
        ),
                const SizedBox(height: 8),
        // Delivery Location - Full width
        _buildCompactDetailItem(AppLocalizations.of(context).deliveryLocation, order.orderCustomer.displayLocation, Icons.location_on_rounded),
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
  
  String _localizedPeriodLabel(BuildContext context, String key, String fallback) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'all':
        return l10n.allTime;
      case 'today':
        return l10n.today;
      case 'week':
        return l10n.thisWeek;
      case 'month':
        return l10n.thisMonth;
      case 'year':
        return l10n.thisYear;
      default:
        return fallback;
    }
  }

  String _localizeOrderStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    final s = status.toLowerCase();
    if (s.contains('completed')) return l10n.completedStatus; // fallback to status label if exists
    if (s.contains('pending')) return l10n.pendingLower;
    if (s.contains('canceled') || s.contains('cancelled')) return l10n.canceledStatus;
    if (s.contains('returned')) return l10n.returnedStatus;
    if (s.contains('in stock')) return l10n.inStockStatus;
    return status;
  }

  String _localizeOrderType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context);
    final t = type.toLowerCase();
    if (t.contains('deliver')) return l10n.deliver;
    if (t.contains('exchange')) return l10n.exchangeType;
    if (t.contains('return')) return l10n.returnType;
    if (t.contains('cash')) return l10n.cashCollectionType;
    return type;
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

  String _getFeeDescriptionLocalized(BuildContext context, CashCycleOrder order) {
    final l10n = AppLocalizations.of(context);
    switch (order.orderStatus) {
      case 'canceled':
        return l10n.cancellationFees;
      case 'returned':
        return l10n.returnFees;
      case 'returnCompleted':
        return l10n.returnCompletedFees;
      default:
        return l10n.platformFee;
    }
  }

  String _formatPaymentReleaseDateLocalized(BuildContext context, CashCycleOrder order) {
    final l10n = AppLocalizations.of(context);
    if (order.moneyReleaseDate == null) {
      return l10n.paymentPending;
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
      // Request storage permissions before downloading
      final hasPermissions = await PermissionService.hasStoragePermissions();
      if (!hasPermissions) {
        final permissionGranted = await PermissionService.requestStoragePermissions(context);
        if (!permissionGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context).storagePermissionExcel),
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
          return;
        }
      }
      
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
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context).excelReadyToSave),
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
        throw Exception(AppLocalizations.of(context).invalidExportResponse);
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
                Expanded(child: Text('${AppLocalizations.of(context).exportFailedPrefix}$e')),
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
      
      // Get app documents directory (most reliable)
      final appDocDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDocDir.path}/$filename';
      final file = File(filePath);
      
      // Write the binary data to app documents directory
      await file.writeAsBytes(binaryData);
      
      print('Excel file saved to app documents: $filePath (${binaryData.length} bytes)');
      
      // Share the file so user can save it to Downloads
      await _shareExcelFile(file, filename);
      
    } catch (e) {
      throw Exception('Failed to prepare Excel file: $e');
    }
  }
  
  /// Share Excel file so user can save it to Downloads
  Future<void> _shareExcelFile(File file, String filename) async {
    try {
      // Use share_plus to share the file
      // This will open the system share dialog where user can save to Downloads
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Excel file: $filename',
        subject: 'Cash Cycle Export - $filename',
      );
      
      print('Excel file shared successfully');
    } catch (e) {
      print('Error sharing Excel file: $e');
      // Fallback: try to open the file directly
      await _openExcelFile(file.path);
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