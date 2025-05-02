import 'package:flutter/material.dart';
import 'cash_cycle_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            Container(
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'EGP 2,750.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Withdrawal info cards
            Row(
              children: [
                // Withdrawal Frequency Card
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.loop,
                    title: 'Withdraw Frequency',
                    value: 'Weekly',
                  ),
                ),
                const SizedBox(width: 16),
                // Next Withdrawal Date Card
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Next Withdraw Date',
                    value: 'Wednesday, April 30, 2025',
                    isDate: true,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Transaction history
            const Text(
              'Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // List of transactions
            _buildTransactionItem(
              title: 'Order Payment',
              date: 'Apr 18, 2025',
              amount: '- EGP 150.00',
              isExpense: true,
              transactionId: '1234567890abcdef',
            ),
            
            _buildTransactionItem(
              title: 'Added Funds',
              date: 'Apr 15, 2025',
              amount: '+ EGP 1,000.00',
              isExpense: false,
              transactionId: 'abcdef1234567890',
            ),
            
            _buildTransactionItem(
              title: 'Order Payment',
              date: 'Apr 10, 2025',
              amount: '- EGP 320.00',
              isExpense: true,
              transactionId: 'fedcba0987654321',
            ),
            
            _buildTransactionItem(
              title: 'Withdrawal',
              date: 'Apr 5, 2025',
              amount: '- EGP 500.00',
              isExpense: true,
              transactionId: '0987654321fedcba',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
                 // overflow: TextOverflow.ellipsis,
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
  
  Widget _buildTransactionItem({
    required String title,
    required String date,
    required String amount,
    required bool isExpense,
    String? transactionId,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isExpense 
                  ? Colors.red.withOpacity(0.1) 
                  : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpense ? Icons.arrow_upward : Icons.arrow_downward,
              color: isExpense ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                if (transactionId != null)
                  Text(
                    'ID: ${transactionId.substring(0, 8)}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
               //const SizedBox(height: 1),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.green,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}