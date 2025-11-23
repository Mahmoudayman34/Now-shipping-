import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_providers.dart';
import '../../../auth/services/auth_service.dart';
import 'package:now_shipping/core/l10n/app_localizations.dart';
import 'package:now_shipping/core/utils/error_message_parser.dart';

class ExportTransactionsWidget extends ConsumerStatefulWidget {
  const ExportTransactionsWidget({super.key});

  @override
  ConsumerState<ExportTransactionsWidget> createState() => _ExportTransactionsWidgetState();
}

class _ExportTransactionsWidgetState extends ConsumerState<ExportTransactionsWidget> {
  String _selectedTimePeriod = 'month';
  String _selectedStatusFilter = 'all';
  String _selectedTransactionType = 'all';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - Fixed at top
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.file_download,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).exportTransactions,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          
          // Time Period Filter
          _buildFilterSection(
            title: AppLocalizations.of(context).timePeriod,
            child: _buildTimePeriodFilter(),
          ),
          
          const SizedBox(height: 20),
          
          // Status Filter
          _buildFilterSection(
            title: AppLocalizations.of(context).statusFilter,
            child: _buildStatusFilter(),
          ),
          
          const SizedBox(height: 20),
          
          // Transaction Type Filter
          _buildFilterSection(
            title: AppLocalizations.of(context).transactionType,
            child: _buildTransactionTypeFilter(),
          ),
          
          const SizedBox(height: 20),
          
          // Custom Date Range
          _buildFilterSection(
            title: AppLocalizations.of(context).customDateRangeOptional,
            child: _buildCustomDateRange(),
          ),
          
                ],
              ),
            ),
          ),
          
          // Export Button - Fixed at bottom
          Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportTransactions,
                icon: _isExporting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.file_download),
                label: Text(_isExporting ? AppLocalizations.of(context).exporting : AppLocalizations.of(context).exportToExcel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTimePeriodFilter() {
    final timePeriods = [
      {'key': 'all', 'label': AppLocalizations.of(context).allTime},
      {'key': 'today', 'label': AppLocalizations.of(context).today},
      {'key': 'week', 'label': AppLocalizations.of(context).thisWeek},
      {'key': 'month', 'label': AppLocalizations.of(context).thisMonth},
      {'key': 'year', 'label': AppLocalizations.of(context).thisMonth},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...timePeriods.map((period) {
            final isSelected = _selectedTimePeriod == period['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTimePeriod = period['key']!;
                      // Clear custom dates when selecting preset period
                      _dateFrom = null;
                      _dateTo = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.orange : Colors.grey.shade100,
                    foregroundColor: isSelected ? Colors.white : Colors.black87,
                    elevation: isSelected ? 2 : 0,
                    shadowColor: Colors.grey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? Colors.orange : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  child: Text(
                    period['label']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      {'key': 'all', 'label': AppLocalizations.of(context).allStatus},
      {'key': 'settled', 'label': AppLocalizations.of(context).settled},
      {'key': 'pending', 'label': AppLocalizations.of(context).pendingLower},
    ];

    return Row(
      children: statuses.map((status) {
        final isSelected = _selectedStatusFilter == status['key'];
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedStatusFilter = status['key']!;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.orange : Colors.grey.shade100,
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                elevation: isSelected ? 2 : 0,
                shadowColor: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? Colors.orange : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                status['label']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionTypeFilter() {
    final types = [
      {'key': 'all', 'label': AppLocalizations.of(context).allTypes},
      {'key': 'cashCycle', 'label': AppLocalizations.of(context).cashCycle},
      {'key': 'fees', 'label': AppLocalizations.of(context).serviceFees},
      {'key': 'pickupFees', 'label': AppLocalizations.of(context).pickupFees},
      {'key': 'refund', 'label': AppLocalizations.of(context).refund},
      {'key': 'deposit', 'label': AppLocalizations.of(context).deposit},
      {'key': 'withdrawal', 'label': AppLocalizations.of(context).withdrawal},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _selectedTransactionType == type['key'];
        return ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedTransactionType = type['key']!;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.orange : Colors.grey.shade100,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            elevation: isSelected ? 2 : 0,
            shadowColor: Colors.grey.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? Colors.orange : Colors.grey.shade300,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            type['label']!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomDateRange() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: AppLocalizations.of(context).fromDate,
                date: _dateFrom,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: AppLocalizations.of(context).toDate,
                date: _dateTo,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
        if (_dateFrom != null || _dateTo != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _dateFrom = null;
                      _dateTo = null;
                      _selectedTimePeriod = 'all';
                    });
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: Text(AppLocalizations.of(context).clearDates),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade300),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDateField({required String label, required DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.grey.shade600,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null 
                    ? '${date.day}/${date.month}/${date.year}'
                    : label,
                style: TextStyle(
                  color: date != null ? Colors.black87 : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate 
          ? (_dateFrom ?? DateTime.now())
          : (_dateTo ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _dateFrom = picked;
          // If from date is after to date, clear to date
          if (_dateTo != null && picked.isAfter(_dateTo!)) {
            _dateTo = null;
          }
        } else {
          _dateTo = picked;
          // If to date is before from date, clear from date
          if (_dateFrom != null && picked.isBefore(_dateFrom!)) {
            _dateFrom = null;
          }
        }
        // Clear preset time period when custom dates are selected
        _selectedTimePeriod = 'all';
      });
    }
  }

  Future<void> _exportTransactions() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Note: No storage permissions needed - using share_plus which handles file sharing
      // Files are saved to app documents directory and shared via system share dialog
      
      final transactionService = ref.read(transactionServiceProvider);
      final authService = AuthService();
      
      // Get authentication token
      final token = await authService.getToken();
      if (token == null) {
        throw Exception(AppLocalizations.of(context).noAuthToken);
      }
      
      await transactionService.exportTransactions(
        timePeriod: _selectedTimePeriod,
        statusFilter: _selectedStatusFilter,
        transactionType: _selectedTransactionType,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        token: token,
        context: context,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).excelExportedSuccessfully,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context).filtersLabel} ${_getFilterDescription()}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).useShareDialogToSave,
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('${AppLocalizations.of(context).exportFailedPrefix}${ErrorMessageParser.parseError(e)}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _getFilterDescription() {
    final List<String> filters = [];
    final l10n = AppLocalizations.of(context);
    
    // Time period
    switch (_selectedTimePeriod) {
      case 'today':
        filters.add(l10n.today);
        break;
      case 'week':
        filters.add(l10n.thisWeek);
        break;
      case 'month':
        filters.add(l10n.thisMonth);
        break;
      case 'year':
        // No dedicated key; reuse thisMonth for brevity or keep English year
        filters.add(l10n.thisMonth);
        break;
      case 'all':
        filters.add(l10n.allTime);
        break;
    }
    
    // Custom dates override time period
    if (_dateFrom != null && _dateTo != null) {
      filters.clear();
      filters.add('${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year} - ${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}');
    }
    
    // Status filter
    if (_selectedStatusFilter != 'all') {
      filters.add(_selectedStatusFilter == 'settled' ? l10n.settled : l10n.pendingLower);
    }
    
    // Transaction type
    if (_selectedTransactionType != 'all') {
      switch (_selectedTransactionType) {
        case 'cashCycle':
          filters.add(l10n.cashCycle);
          break;
        case 'fees':
          filters.add(l10n.serviceFees);
          break;
        case 'pickupFees':
          filters.add(l10n.pickupFees);
          break;
        case 'refund':
          filters.add(l10n.refund);
          break;
        case 'deposit':
          filters.add(l10n.deposit);
          break;
        case 'withdrawal':
          filters.add(l10n.withdrawal);
          break;
      }
    }
    
    return filters.join(', ');
  }
}
