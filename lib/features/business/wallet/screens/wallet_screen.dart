import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cash_cycle_screen.dart';
import 'package:now_shipping/core/l10n/app_localizations.dart';
import '../../../../core/mixins/refreshable_screen_mixin.dart';
import '../providers/transaction_providers.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../widgets/export_transactions_widget.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> with RefreshableScreenMixin {
  
  @override
  void initState() {
    super.initState();
    // Register refresh callback for tab tap refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerRefreshCallback(_refreshWallet, 3);
    });
  }
  
  @override
  void dispose() {
    // Unregister refresh callback
    unregisterRefreshCallback(3);
    super.dispose();
  }
  
  void _refreshWallet() {
    // Refresh wallet data
    ref.invalidate(walletBalanceProvider);
    ref.invalidate(transactionsProvider(ref.read(selectedTimePeriodProvider)));
  }

  @override
  Widget build(BuildContext context) {
    final selectedTimePeriod = ref.watch(selectedTimePeriodProvider);
    final walletState = ref.watch(walletBalanceProvider);
    final transactionsState = ref.watch(transactionsProvider(selectedTimePeriod));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context).walletTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshWallet();
        },
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            _buildBalanceCard(walletState),
            
            const SizedBox(height: 24),
            
            // Withdrawal info cards
            _buildWithdrawalInfoCards(walletState),
            
            const SizedBox(height: 24),
            
            // Transaction history section
            _buildTransactionHistorySection(transactionsState, selectedTimePeriod),
          ],
        ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'wallet_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CashCycleScreen()),
          );
        },
        backgroundColor: const Color(0xfff29620),
        child: const Icon(Icons.swap_horiz, color: Colors.white, size: 30),
      ),
    );
  }
  
  Widget _buildBalanceCard(AsyncValue<WalletModel> walletState) {
    return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xfff29620), Color(0xFFEA6B35)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
      child: walletState.when(
        data: (wallet) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).totalBalance,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              wallet.formattedBalance,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (wallet.unsettledTransactions > 0) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)
                    .balanceRecalculatedUnsettled
                    .replaceAll('{count}', wallet.unsettledTransactions.toString()),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
              AppLocalizations.of(context).totalBalance,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
              AppLocalizations.of(context).loading,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
        ),
        error: (error, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).totalBalance,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).errorLoadingBalance,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalInfoCards(AsyncValue<WalletModel> walletState) {
    return walletState.when(
      data: (wallet) => Row(
              children: [
                // Withdrawal Frequency Card
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.loop,
                    title: AppLocalizations.of(context).withdrawFrequency,
              value: _localizeFrequency(wallet.withdrawalFrequency),
                  ),
                ),
                const SizedBox(width: 16),
                // Next Withdrawal Date Card
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: AppLocalizations.of(context).nextWithdrawDate,
              value: wallet.formattedNextWithdrawalDate,
                    isDate: true,
                  ),
                ),
              ],
            ),
      loading: () => Row(
        children: [
          Expanded(child: _buildInfoCard(icon: Icons.loop, title: AppLocalizations.of(context).withdrawFrequency, value: AppLocalizations.of(context).loading)),
          const SizedBox(width: 16),
          Expanded(child: _buildInfoCard(icon: Icons.calendar_today, title: AppLocalizations.of(context).nextWithdrawDate, value: AppLocalizations.of(context).loading, isDate: true)),
        ],
      ),
      error: (_, __) => Row(
        children: [
          Expanded(child: _buildInfoCard(icon: Icons.loop, title: AppLocalizations.of(context).withdrawFrequency, value: AppLocalizations.of(context).error)),
          const SizedBox(width: 16),
          Expanded(child: _buildInfoCard(icon: Icons.calendar_today, title: AppLocalizations.of(context).nextWithdrawDate, value: AppLocalizations.of(context).error, isDate: true)),
        ],
      ),
    );
  }

  Widget _buildTransactionHistorySection(AsyncValue<List<TransactionModel>> transactionsState, String selectedTimePeriod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transaction History Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).transactionHistory,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showExportDialog(),
              icon: const Icon(Icons.download, size: 16),
              label: Text(AppLocalizations.of(context).export),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xfff29620),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).financialTransactionsHelp,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        
        // Filter buttons
        _buildFilterButtons(selectedTimePeriod),
            
            const SizedBox(height: 16),
            
        // Transactions list
        transactionsState.when(
          data: (transactions) => transactions.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      AppLocalizations.of(context).noTransactionsFound,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: transactions.map((transaction) => _buildTransactionItem(transaction)).toList(),
                ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).errorLoadingTransactions,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _refreshWallet,
                    child: Text(AppLocalizations.of(context).retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButtons(String selectedTimePeriod) {
    final timePeriods = [
      {'key': 'all', 'label': AppLocalizations.of(context).allTime},
      {'key': 'today', 'label': AppLocalizations.of(context).today},
      {'key': 'week', 'label': AppLocalizations.of(context).thisWeek},
      {'key': 'month', 'label': AppLocalizations.of(context).thisMonth},
      {'key': 'year', 'label': AppLocalizations.of(context).thisMonth},
    ];

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
            AppLocalizations.of(context).timePeriod,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...timePeriods.map((period) {
                  final isSelected = selectedTimePeriod == period['key'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                        onPressed: () {
                          ref.read(selectedTimePeriodProvider.notifier).state = period['key']!;
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
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient background
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: transaction.isPositive 
                    ? [Colors.green.shade50, Colors.green.shade100]
                    : [Colors.red.shade50, Colors.red.shade100],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Transaction type icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: transaction.isPositive 
                        ? Colors.green.shade600 
                        : Colors.red.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    transaction.isPositive ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _localizeTransactionType(transaction.displayType),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: transaction.isPositive 
                              ? Colors.green.shade800 
                              : Colors.red.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.transactionId,
                        style: TextStyle(
                          color: transaction.isPositive 
                              ? Colors.green.shade600 
                              : Colors.red.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: transaction.isPositive 
                        ? Colors.green.shade600 
                        : Colors.red.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    transaction.formattedAmount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfessionalDetailRow(
                  AppLocalizations.of(context).transactionDate, 
                  transaction.formattedDate,
                  Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                _buildProfessionalDetailRow(
                  AppLocalizations.of(context).transactionTypeLabel, 
                  _localizeTransactionType(transaction.displayType),
                  Icons.category,
                ),
                const SizedBox(height: 12),
                _buildProfessionalDetailRow(
                  AppLocalizations.of(context).amountWithCurrency, 
                  transaction.formattedAmount,
                  Icons.attach_money,
                ),
                const SizedBox(height: 12),
                _buildProfessionalDetailRow(
                  AppLocalizations.of(context).status, 
                  _localizeTransactionStatus(transaction.statusDisplay),
                  Icons.check_circle_outline,
                ),
                
                // Transaction notes if available
                if (transaction.transactionNotes != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.blue.shade100],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note_alt,
                          color: Colors.blue.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            transaction.transactionNotes!,
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDetailRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _localizeTransactionType(String raw) {
    final l10n = AppLocalizations.of(context);
    final key = raw.toLowerCase();
    if (key.contains('cash') && key.contains('cycle')) return l10n.cashCycle;
    if (key == 'withdrawal') return l10n.withdrawal;
    if (key.contains('service') && key.contains('fees')) return l10n.serviceFees;
    if (key.contains('pickup') && key.contains('fees')) return l10n.pickupFees;
    if (key == 'refund') return l10n.refund;
    if (key == 'deposit') return l10n.deposit;
    // Fallback: return same string
    return raw;
  }

  String _localizeTransactionStatus(String raw) {
    final l10n = AppLocalizations.of(context);
    if (raw.toLowerCase().startsWith('settled')) {
      return raw.replaceFirst(RegExp('Settled', caseSensitive: false), l10n.settled);
    }
    if (raw.toLowerCase().contains('pending')) return l10n.pendingLower;
    return raw;
  }

  String _localizeFrequency(String freq) {
    final f = freq.toLowerCase();
    final l10n = AppLocalizations.of(context);
    if (f.contains('week')) return l10n.weekly;
    if (f.contains('day')) return l10n.daily;
    if (f.contains('month')) return l10n.monthly;
    if (f.contains('bi') && f.contains('week')) return l10n.biweekly;
    return freq;
  }

  void _showExportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExportTransactionsWidget(),
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool isDate = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isDate ? 14 : 16,
              color: Colors.grey[800],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}