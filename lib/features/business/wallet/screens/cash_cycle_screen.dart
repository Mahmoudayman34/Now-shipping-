import 'package:flutter/material.dart';

class CashCycleScreen extends StatelessWidget {
  const CashCycleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Cycle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff2F2F2F)),
          onPressed: () => Navigator.pop(context),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.file_download_outlined),
        //     onPressed: () {
        //       // Export functionality
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Four statistics cards in a row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'TOTAL INCOME',
                    value: '89996.00EGP',
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'TOTAL FEES',
                    value: '750.00EGP',
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'NET TOTAL',
                    value: '89246.00EGP',
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'COMPLETED ORDERS',
                    value: '7',
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Transaction history header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // TextButton.icon(
                //   onPressed: () {
                //     // Export functionality
                //   },
                //   icon: const Icon(Icons.file_download_outlined, size: 18),
                //   label: const Text('Export'),
                //   style: TextButton.styleFrom(
                //     foregroundColor: Colors.blue,
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'View all your order transactions and fees',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Transaction table as cards
            _buildTransactionCard(
              orderId: '#366992',
              orderType: 'Deliver',
              status: 'completed',
              pickupDate: 'Mar 17, 2025',
              orderLocation: 'Alexandria',
              totalAmount: '2000.00EGP',
              fees: '110.00EGP',
              depositDate: 'Mar 24, 2025',
              moneyReleaseDate: 'Wed, Mar 26, 2025',
            ),
            
            _buildTransactionCard(
              orderId: '#756437',
              orderType: 'Exchange',
              status: 'completed',
              pickupDate: 'Mar 17, 2025',
              orderLocation: 'Alexandria',
              totalAmount: '10000.00EGP',
              fees: '110.00EGP',
              depositDate: 'Mar 24, 2025',
              moneyReleaseDate: 'Wed, Mar 26, 2025',
            ),
            
            _buildTransactionCard(
              orderId: '#481379',
              orderType: 'Exchange',
              status: 'completed',
              pickupDate: 'Mar 23, 2025',
              orderLocation: 'Cairo',
              totalAmount: '10000.00EGP',
              fees: '80.00EGP',
              depositDate: 'Mar 24, 2025',
              moneyReleaseDate: 'Wed, Mar 26, 2025',
            ),
            
            _buildTransactionCard(
              orderId: '#607903',
              orderType: 'Deliver',
              status: 'completed',
              pickupDate: 'Mar 23, 2025',
              orderLocation: 'Cairo',
              totalAmount: '22996.00EGP',
              fees: '90.00EGP',
              depositDate: 'Mar 24, 2025',
              moneyReleaseDate: 'Wed, Mar 26, 2025',
            ),
            
            _buildTransactionCard(
              orderId: '#223323',
              orderType: 'Deliver',
              status: 'completed',
              pickupDate: 'Mar 26, 2025',
              orderLocation: 'Cairo',
              totalAmount: '15000.00EGP',
              fees: '120.00EGP',
              depositDate: 'Mar 26, 2025',
              moneyReleaseDate: 'Wed, Apr 2, 2025',
            ),
            
            _buildTransactionCard(
              orderId: '#618871',
              orderType: 'Deliver',
              status: 'completed',
              pickupDate: 'Mar 30, 2025',
              orderLocation: 'Alexandria',
              totalAmount: '10000.00EGP',
              fees: '120.00EGP',
              depositDate: 'Mar 30, 2025',
              moneyReleaseDate: 'Wed, Apr 2, 2025',
            ),
            
            _buildTransactionCard(
              orderId: '#256746',
              orderType: 'Deliver',
              status: 'completed',
              pickupDate: 'Apr 11, 2025',
              orderLocation: 'Cairo',
              totalAmount: '20000.00EGP',
              fees: '120.00EGP',
              depositDate: 'Apr 11, 2025',
              moneyReleaseDate: 'Wed, Apr 16, 2025',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
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
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard({
    required String orderId,
    required String orderType,
    required String status,
    required String pickupDate,
    required String orderLocation,
    required String totalAmount,
    required String fees,
    required String depositDate,
    required String moneyReleaseDate,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          // Order ID and Type
            Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text(
                orderId,
                style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 16,
                ),
              ),
              Expanded(
                child: Center(
                child: Text(
                  orderType,
                  style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal,

                  ),
                ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                status,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                ),
                ),
              ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildDetailRow("Pickup Date", pickupDate),
                const SizedBox(height: 8),
                _buildDetailRow("Order Location", orderLocation),
                const SizedBox(height: 8),
                _buildDetailRow("Total Amount", totalAmount),
                const SizedBox(height: 8),
                _buildDetailRow("Fees", fees),
                const SizedBox(height: 8),
                _buildDetailRow("Deposit Date", depositDate),
                const SizedBox(height: 8),
                _buildDetailRow("Money Release Date", moneyReleaseDate),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}