import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/features/business/orders/providers/orders_provider.dart';
import 'package:tes1/features/business/orders/screens/order_details_screen_refactored.dart';
import 'package:tes1/features/business/orders/widgets/empty_orders_state.dart';
import 'package:tes1/features/business/orders/widgets/order_item.dart';
import 'package:tes1/features/business/orders/widgets/order_tab.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedOrderTabProvider);
    final filteredOrders = ref.watch(filteredOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders', style: TextStyle(color: Color(0xff2F2F2F))),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xff2F2F2F)),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar for Orders categories
          _buildTabBar(selectedTab),
          
          // Order list or empty state
          Expanded(
            child: filteredOrders.isNotEmpty
              ? ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return OrderItem(
                      orderId: order['orderId'],
                      customerName: order['customerName'],
                      location: order['location'],
                      amount: order['amount'],
                      status: order['status'],
                      onTap: () => _navigateToOrderDetails(order),
                    );
                  }
                )
              : const EmptyOrdersState(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabBar(String selectedTab) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildTabItem('All', selectedTab),
          _buildTabItem('New', selectedTab),
          _buildTabItem('Picked Up', selectedTab),
          _buildTabItem('In Stock', selectedTab),
          _buildTabItem('In Progress', selectedTab),
          _buildTabItem('Heading To Customer', selectedTab),
          _buildTabItem('Heading To You', selectedTab),
          _buildTabItem('Completed', selectedTab),
          _buildTabItem('Canceled', selectedTab),
          _buildTabItem('Rejected', selectedTab),
          _buildTabItem('Returned', selectedTab),
          _buildTabItem('Terminated', selectedTab),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, String selectedTab) {
    return OrderTab(
      title: title,
      isSelected: selectedTab == title,
      onTap: () => ref.read(selectedOrderTabProvider.notifier).state = title,
    );
  }

  void _navigateToOrderDetails(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreenRefactored(
          orderId: order['orderId'],
          status: order['status'],
        ),
      ),
    );
  }
}