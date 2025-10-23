class WalletModel {
  final double totalBalance;
  final int unsettledTransactions;
  final DateTime? nextWithdrawalDate;
  final String withdrawalFrequency;
  final DateTime? lastUpdated;

  const WalletModel({
    required this.totalBalance,
    required this.unsettledTransactions,
    this.nextWithdrawalDate,
    required this.withdrawalFrequency,
    this.lastUpdated,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
      unsettledTransactions: json['unsettledTransactions'] ?? 0,
      nextWithdrawalDate: json['nextWithdrawalDate'] != null 
          ? DateTime.parse(json['nextWithdrawalDate'])
          : null,
      withdrawalFrequency: json['withdrawalFrequency'] ?? 'Weekly',
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'unsettledTransactions': unsettledTransactions,
      'nextWithdrawalDate': nextWithdrawalDate?.toIso8601String(),
      'withdrawalFrequency': withdrawalFrequency,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Helper methods for UI display
  String get formattedBalance {
    return '${totalBalance.toStringAsFixed(0)} EGP';
  }

  String get formattedNextWithdrawalDate {
    if (nextWithdrawalDate == null) return 'Not set';
    
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    final weekday = weekdays[nextWithdrawalDate!.weekday - 1];
    final month = months[nextWithdrawalDate!.month - 1];
    final day = nextWithdrawalDate!.day;
    final year = nextWithdrawalDate!.year;
    
    return '$weekday, $month $day, $year';
  }

  String get balanceNote {
    if (unsettledTransactions > 0) {
      return 'Balance recalculated from $unsettledTransactions unsettled transactions.';
    }
    return 'All transactions are settled.';
  }
}
