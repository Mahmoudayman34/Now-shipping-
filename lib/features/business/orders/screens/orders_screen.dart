import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:now_shipping/features/business/orders/providers/orders_provider.dart';
import 'package:now_shipping/features/business/orders/screens/order_details_screen_refactored.dart';
import 'package:now_shipping/features/business/orders/screens/create_order/create_order_screen.dart';
import 'package:now_shipping/features/business/orders/widgets/order_item.dart';
import 'package:now_shipping/features/business/orders/widgets/order_tab.dart';
import 'package:now_shipping/features/common/widgets/shimmer_loading.dart';

// Provider to keep track of the selected delivery type filter
final deliveryTypeFilterProvider = StateProvider<String>((ref) => 'All');

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> with SingleTickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // Initialize the rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(); // Makes it rotate continuously
    
    // Force refresh orders when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }
  
  @override
  void dispose() {
    _refreshController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    final fetchOrders = ref.read(fetchOrdersProvider);
    final deliveryTypeFilter = ref.read(deliveryTypeFilterProvider);
    
    try {
      // Get the OrderService to make the API call with the filter
      final orderService = ref.read(orderServiceProvider);
      
      // Set loading state
      ref.read(ordersLoadingStateProvider.notifier).state = OrderLoadingState.loading;
      
      // Fetch orders with the delivery type filter
      final orders = await orderService.getAllOrders(orderType: deliveryTypeFilter);
      
      // Update orders data
      ref.read(ordersDataProvider.notifier).state = orders;
      
      // Set loaded state
      ref.read(ordersLoadingStateProvider.notifier).state = OrderLoadingState.loaded;
    } catch (e) {
      print('Error fetching orders: $e');
      ref.read(ordersLoadingStateProvider.notifier).state = OrderLoadingState.error;
    }
    
    _refreshController.refreshCompleted();
  }

  void _onRefresh() async {
    // Refresh orders data
    await _fetchOrders();
  }

  // Show the filter options bottom sheet
  void _showFilterOptions() {
    final currentFilter = ref.read(deliveryTypeFilterProvider);
    String selectedFilter = currentFilter; // Track selection locally
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter by Delivery Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter options
                  _buildFilterOption('All', 'All', selectedFilter, (value) {
                    setState(() => selectedFilter = value);
                  }),
                  _buildFilterOption('Deliver', 'Deliver', selectedFilter, (value) {
                    setState(() => selectedFilter = value);
                  }),
                  _buildFilterOption('Exchange', 'Exchange', selectedFilter, (value) {
                    setState(() => selectedFilter = value);
                  }),
                  _buildFilterOption('Return', 'Return', selectedFilter, (value) {
                    setState(() => selectedFilter = value);
                  }),
                  _buildFilterOption('Cash Collection', 'Cash Collection', selectedFilter, (value) {
                    setState(() => selectedFilter = value);
                  }),
                  
                  const SizedBox(height: 20),
                  
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Update the provider and apply filter only when the Apply button is pressed
                        ref.read(deliveryTypeFilterProvider.notifier).state = selectedFilter;
                        Navigator.pop(context);
                        // Refresh orders with the new filter
                        _fetchOrders();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26A2B9),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Apply Filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // Build a single filter option
  Widget _buildFilterOption(String label, String value, String currentFilter, Function(String) onSelect) {
    return InkWell(
      onTap: () => onSelect(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              value == currentFilter
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
              color: const Color(0xFF26A2B9),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2F2F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final loadingState = ref.watch(ordersLoadingStateProvider);
    final selectedTab = ref.watch(selectedOrderTabProvider);
    final deliveryTypeFilter = ref.watch(deliveryTypeFilterProvider);
    final filteredOrders = ref.watch(filteredOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders', style: TextStyle(color: Color(0xff2F2F2F))),
        backgroundColor: Colors.white,
        actions: [
          // Badge to show if filter is active
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Color(0xff2F2F2F)),
                onPressed: _showFilterOptions,
              ),
              if (deliveryTypeFilter != 'All')
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9800),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar for Orders categories
          _buildTabBar(selectedTab),
          
          // Order list, loading state, error state or empty state
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              header: ClassicHeader(
                refreshStyle: RefreshStyle.Follow,
                idleIcon: const Icon(Icons.arrow_downward, color: Color(0xFFFF9800)),
                releaseIcon: const Icon(Icons.refresh, color: Color(0xFFFF9800)),
                refreshingIcon: RotationTransition(
                  turns: _rotationController,
                  child: SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: Image.asset(
                      'assets/icons/icon_only.png',
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ),
                completeIcon: const Icon(Icons.check, color: Colors.green),
                failedIcon: const Icon(Icons.error, color: Colors.red),
                textStyle: const TextStyle(color: Color(0xFF757575)),
                idleText: "Pull down to refresh",
                releaseText: "Release to refresh",
                refreshingText: "Refreshing...",
                completeText: "Refresh completed",
                failedText: "Refresh failed",
              ),
              child: _buildOrderContent(loadingState, filteredOrders, selectedTab),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderContent(OrderLoadingState state, List<Map<String, dynamic>> orders, String selectedTab) {
    switch (state) {
      case OrderLoadingState.initial:
      case OrderLoadingState.loading:
        return _buildLoadingState();
        
      case OrderLoadingState.loaded:
        if (orders.isEmpty) {
          return _buildEmptyState(selectedTab);
        } else {
          return ListView.builder(
            itemCount: orders.length,
                  itemBuilder: (context, index) {
              final order = orders[index];
                    return OrderItem(
                      orderId: order['orderId'],
                      customerName: order['customerName'],
                      location: order['location'],
                      amount: order['amount'],
                      status: order['status'],
                      orderType: order['deliveryType'] ?? 'Deliver',
                      attempts: order['attempts'] ?? 0,
                      phoneNumber: order['phoneNumber'] ?? '',
                      onTap: () => _navigateToOrderDetails(order),
                    );
                  }
          );
        }
        
      case OrderLoadingState.error:
        return _buildErrorState();
    }
  }
  
  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return const ShimmerListItem(
          height: 80,
          hasLeadingCircle: false, 
          hasTrailingBox: true,
          lines: 3,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      },
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your connection and try again',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchOrders,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(String selectedTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty illustration
          Image.asset(
            'assets/icons/icon_only.png',
            width: 100,
            height: 100,
            color: Colors.grey[300],
            // Handle if image is missing, show a placeholder icon
            errorBuilder: (context, error, stackTrace) => 
                Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          
          // Message
          Text(
            selectedTab == 'All' 
                ? "You didn't create orders yet!"
                : "No orders with status \"$selectedTab\"",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Create Order Button - Matching the pickups screen style
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _navigateToCreateOrder(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                elevation: 0,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFF6D00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Create Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabBar(String selectedTab) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
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
    final isSelected = selectedTab == title;
    return OrderTab(
      title: title,
      isSelected: isSelected,
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
    ).then((_) => _fetchOrders());
  }
  
  void _navigateToCreateOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateOrderScreen(),
      ),
    ).then((_) => _fetchOrders());
  }
}