import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_providers.dart';
import '../../../auth/services/auth_service.dart';

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
                const Expanded(
                  child: Text(
                    'Export Transactions',
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
            title: 'Time Period',
            child: _buildTimePeriodFilter(),
          ),
          
          const SizedBox(height: 20),
          
          // Status Filter
          _buildFilterSection(
            title: 'Status Filter',
            child: _buildStatusFilter(),
          ),
          
          const SizedBox(height: 20),
          
          // Transaction Type Filter
          _buildFilterSection(
            title: 'Transaction Type',
            child: _buildTransactionTypeFilter(),
          ),
          
          const SizedBox(height: 20),
          
          // Custom Date Range
          _buildFilterSection(
            title: 'Custom Date Range (Optional)',
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
                label: Text(_isExporting ? 'Exporting...' : 'Export to Excel'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildTimePeriodFilter() {
    final timePeriods = [
      {'key': 'today', 'label': 'Today'},
      {'key': 'week', 'label': 'This Week'},
      {'key': 'month', 'label': 'This Month'},
      {'key': 'year', 'label': 'This Year'},
      {'key': 'all', 'label': 'All Time'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: timePeriods.map((period) {
        final isSelected = _selectedTimePeriod == period['key'];
        return FilterChip(
          label: Text(period['label']!),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedTimePeriod = period['key']!;
                // Clear custom dates when selecting preset period
                _dateFrom = null;
                _dateTo = null;
              });
            }
          },
          selectedColor: Colors.blue.withOpacity(0.2),
          checkmarkColor: Colors.blue,
          backgroundColor: Colors.grey.shade100,
        );
      }).toList(),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      {'key': 'all', 'label': 'All Status'},
      {'key': 'settled', 'label': 'Settled'},
      {'key': 'pending', 'label': 'Pending'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final isSelected = _selectedStatusFilter == status['key'];
        return FilterChip(
          label: Text(status['label']!),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedStatusFilter = status['key']!;
              });
            }
          },
          selectedColor: Colors.green.withOpacity(0.2),
          checkmarkColor: Colors.green,
          backgroundColor: Colors.grey.shade100,
        );
      }).toList(),
    );
  }

  Widget _buildTransactionTypeFilter() {
    final types = [
      {'key': 'all', 'label': 'All Types'},
      {'key': 'cashCycle', 'label': 'Cash Cycle'},
      {'key': 'fees', 'label': 'Service Fees'},
      {'key': 'pickupFees', 'label': 'Pickup Fees'},
      {'key': 'refund', 'label': 'Refund'},
      {'key': 'deposit', 'label': 'Deposit'},
      {'key': 'withdrawal', 'label': 'Withdrawal'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _selectedTransactionType == type['key'];
        return FilterChip(
          label: Text(type['label']!),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedTransactionType = type['key']!;
              });
            }
          },
          selectedColor: Colors.orange.withOpacity(0.2),
          checkmarkColor: Colors.orange,
          backgroundColor: Colors.grey.shade100,
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
                label: 'From Date',
                date: _dateFrom,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'To Date',
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
                  label: const Text('Clear Dates'),
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
      final transactionService = ref.read(transactionServiceProvider);
      final authService = AuthService();
      
      // Get authentication token
      final token = await authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please log in again.');
      }
      
      await transactionService.exportTransactions(
        timePeriod: _selectedTimePeriod,
        statusFilter: _selectedStatusFilter,
        transactionType: _selectedTransactionType,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        token: token,
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
                    const Expanded(
                      child: Text(
                        'Excel exported successfully!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Filters: ${_getFilterDescription()}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'File opened for you to save',
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
                Expanded(child: Text('Export failed: $e')),
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
    
    // Time period
    switch (_selectedTimePeriod) {
      case 'today':
        filters.add('Today');
        break;
      case 'week':
        filters.add('This Week');
        break;
      case 'month':
        filters.add('This Month');
        break;
      case 'year':
        filters.add('This Year');
        break;
      case 'all':
        filters.add('All Time');
        break;
    }
    
    // Custom dates override time period
    if (_dateFrom != null && _dateTo != null) {
      filters.clear();
      filters.add('${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year} - ${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}');
    }
    
    // Status filter
    if (_selectedStatusFilter != 'all') {
      filters.add(_selectedStatusFilter == 'settled' ? 'Settled' : 'Pending');
    }
    
    // Transaction type
    if (_selectedTransactionType != 'all') {
      switch (_selectedTransactionType) {
        case 'cashCycle':
          filters.add('Cash Cycle');
          break;
        case 'fees':
          filters.add('Service Fees');
          break;
        case 'pickupFees':
          filters.add('Pickup Fees');
          break;
        case 'refund':
          filters.add('Refund');
          break;
        case 'deposit':
          filters.add('Deposit');
          break;
        case 'withdrawal':
          filters.add('Withdrawal');
          break;
      }
    }
    
    return filters.join(', ');
  }
}
