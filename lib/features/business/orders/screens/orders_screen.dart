import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';
import 'package:now_shipping/features/business/orders/providers/orders_provider.dart';
import 'package:now_shipping/features/business/orders/screens/order_details_screen_refactored.dart';
import 'package:now_shipping/features/business/orders/screens/create_order/create_order_screen.dart';
import 'package:now_shipping/features/business/orders/widgets/order_item.dart';
import 'package:now_shipping/features/business/orders/widgets/order_tab.dart';
import 'package:now_shipping/features/common/widgets/shimmer_loading.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import 'package:now_shipping/core/widgets/toast_.dart';
import '../../../../core/mixins/refreshable_screen_mixin.dart';
import '../../../../core/utils/responsive_utils.dart';

// Provider to keep track of the selected delivery type filter
final deliveryTypeFilterProvider = StateProvider<String>((ref) => 'All');

// Provider to store cached user data for this screen
final ordersScreenUserProvider = StateProvider<UserModel?>((ref) => null);

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> with SingleTickerProviderStateMixin, RefreshableScreenMixin {
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
      _preloadUserData(); // Preload user data
      // Register refresh callback for tab tap refresh
      registerRefreshCallback(_onRefresh, 1);
    });
  }
  
  // Preload user data to avoid delay when creating orders
  Future<void> _preloadUserData() async {
    final authService = ref.read(authServiceProvider);
    final user = await authService.getCurrentUser();
    
    // Store in the provider for later use
    ref.read(ordersScreenUserProvider.notifier).state = user;
  }
  
  @override
  void dispose() {
    _refreshController.dispose();
    _rotationController.dispose();
    // Unregister refresh callback
    unregisterRefreshCallback(1);
    super.dispose();
  }

  Future<void> _fetchOrders() async {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 2.5),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final spacing = ResponsiveUtils.getResponsiveSpacing(context);
            final horizontalPadding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
            
            return Padding(
            padding: EdgeInsets.symmetric(
              vertical: spacing * 1.5, 
              horizontal: horizontalPadding.horizontal / 2,
            ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).filterByDeliveryType,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F2F2F),
                    ),
                  ),
                  SizedBox(height: spacing),
                  
                  // Filter options
                  _buildFilterOption(AppLocalizations.of(context).allOrders, 'All', selectedFilter, (value) {
                    setState(() => selectedFilter = value);
                  }),
                  _buildFilterOption(AppLocalizations.of(context).deliverType, 'Deliver', selectedFilter, (value) {
                    setState(() => selectedFilter = value);
                  }),
                  _buildFilterOption(AppLocalizations.of(context).exchangeType, 'Exchange', selectedFilter, (value) {
                    setState(() => selectedFilter = value);
                  }),
                  _buildFilterOption(AppLocalizations.of(context).returnType, 'Return', selectedFilter, (value) {
                    setState(() => selectedFilter = value);
                  }),
                  _buildFilterOption(AppLocalizations.of(context).cashCollectionType, 'Cash Collection', selectedFilter, (value) {
                    setState(() => selectedFilter = value);
                  }),
                  
                  SizedBox(height: spacing * 1.5),
                  
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
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.getResponsiveSpacing(context) * 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(context),
                          ),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).applyFilter,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14, tablet: 16, desktop: 18),
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
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    
    return InkWell(
      onTap: () => onSelect(value),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: spacing * 0.8),
            child: Row(
              children: [
                Icon(
                  value == currentFilter
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                  color: const Color(0xFF26A2B9),
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
                ),
                SizedBox(width: spacing),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14, tablet: 16, desktop: 18),
                    color: const Color(0xFF2F2F2F),
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

    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).orders, 
            style: TextStyle(
              color: const Color(0xff2F2F2F),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 18, 
                tablet: 20, 
                desktop: 22,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          actions: [
            // Badge to show if filter is active
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.filter_list, 
                    color: const Color(0xff2F2F2F),
                    size: ResponsiveUtils.getResponsiveIconSize(context),
                  ),
                  onPressed: _showFilterOptions,
                ),
                if (deliveryTypeFilter != 'All')
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: ResponsiveUtils.getResponsiveSpacing(context) * 0.5,
                      height: ResponsiveUtils.getResponsiveSpacing(context) * 0.5,
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
                physics: const AlwaysScrollableScrollPhysics(),
                header: ClassicHeader(
                  refreshStyle: RefreshStyle.Follow,
                  idleIcon: Icon(
                    Icons.arrow_downward, 
                    color: const Color(0xFFFF9800),
                    size: ResponsiveUtils.getResponsiveIconSize(context),
                  ),
                  releaseIcon: Icon(
                    Icons.refresh, 
                    color: const Color(0xFFFF9800),
                    size: ResponsiveUtils.getResponsiveIconSize(context),
                  ),
                  refreshingIcon: RotationTransition(
                    turns: _rotationController,
                    child: SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(context) * 2.5,
                      height: ResponsiveUtils.getResponsiveSpacing(context) * 2.5,
                      child: Image.asset(
                        'assets/icons/icon_only.png',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                  ),
                  completeIcon: Icon(
                    Icons.check, 
                    color: Colors.green,
                    size: ResponsiveUtils.getResponsiveIconSize(context),
                  ),
                  failedIcon: Icon(
                    Icons.error, 
                    color: Colors.red,
                    size: ResponsiveUtils.getResponsiveIconSize(context),
                  ),
                  textStyle: TextStyle(
                    color: const Color(0xFF757575),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 12, tablet: 14, desktop: 16),
                  ),
                  idleText: AppLocalizations.of(context).pullDownToRefresh,
                  releaseText: AppLocalizations.of(context).releaseToRefresh,
                  refreshingText: AppLocalizations.of(context).refreshingText,
                  completeText: AppLocalizations.of(context).refreshCompleted,
                  failedText: AppLocalizations.of(context).refreshFailedText,
                ),
                child: _buildOrderContent(loadingState, filteredOrders, selectedTab),
              ),
            ),
          ],
        ),
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
          Text(
            AppLocalizations.of(context).errorLoadingOrders,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).checkConnectionRetry,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchOrders,
            child: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(String selectedTab) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = ResponsiveUtils.getResponsiveSpacing(context);
        final imageSize = ResponsiveUtils.getResponsiveImageSize(context) * 2.5;
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty illustration
              Image.asset(
                'assets/icons/icon_only.png',
                width: imageSize,
                height: imageSize,
                color: Colors.grey[300],
                // Handle if image is missing, show a placeholder icon
                errorBuilder: (context, error, stackTrace) => 
                    Icon(Icons.inventory_2_outlined, size: imageSize, color: Colors.grey.shade300),
              ),
              SizedBox(height: spacing * 1.5),
              
              // Message
              Text(
                selectedTab == 'All' 
                    ? AppLocalizations.of(context).noOrdersYet
                    : "${AppLocalizations.of(context).noOrdersWithStatus} \"$selectedTab\"",
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: spacing * 2),
          
              // Create Order Button - Matching the pickups screen style
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context) * 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withOpacity(0.4),
                      blurRadius: ResponsiveUtils.getResponsiveSpacing(context) * 1.5,
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
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context) * 2,
                      ),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF6D00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context) * 2,
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing * 2.5, 
                        vertical: spacing * 1.2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add, 
                            size: ResponsiveUtils.getResponsiveIconSize(context),
                          ),
                          SizedBox(width: spacing * 0.8),
                          Text(
                            AppLocalizations.of(context).createNewOrder,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14, tablet: 16, desktop: 18),
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
      },
    );
  }
  
  Widget _buildTabBar(String selectedTab) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final horizontalPadding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
    final screenType = ResponsiveUtils.getScreenType(context);
    
    // Adjust height based on screen type
    final tabBarHeight = screenType == ScreenType.mobile 
        ? spacing * 5.0  // Full height on mobile
        : screenType == ScreenType.tablet 
            ? spacing * 4.2  // Reduced height on tablet
            : spacing * 4.5;  // Medium height on desktop
    
    return Container(
          height: tabBarHeight,
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
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding.horizontal / 2, 
              vertical: screenType == ScreenType.tablet ? spacing * 0.5 : spacing * 0.8,
            ),
            children: [
              _buildTabItem(AppLocalizations.of(context).allOrders, 'All', selectedTab),
              _buildTabItem(AppLocalizations.of(context).newStatus, 'New', selectedTab),
              _buildTabItem(AppLocalizations.of(context).pickedUpStatus, 'Picked Up', selectedTab),
              _buildTabItem(AppLocalizations.of(context).inStockStatus, 'In Stock', selectedTab),
              _buildTabItem(AppLocalizations.of(context).inProgressStatus, 'In Progress', selectedTab),
              _buildTabItem(AppLocalizations.of(context).headingToCustomerStatus, 'Heading To Customer', selectedTab),
              _buildTabItem(AppLocalizations.of(context).headingToYouStatus, 'Heading To You', selectedTab),
              _buildTabItem(AppLocalizations.of(context).completedStatus, 'Completed', selectedTab),
              _buildTabItem(AppLocalizations.of(context).canceledStatus, 'Canceled', selectedTab),
              _buildTabItem(AppLocalizations.of(context).rejectedStatus, 'Rejected', selectedTab),
              _buildTabItem(AppLocalizations.of(context).returnedStatus, 'Returned', selectedTab),
              _buildTabItem(AppLocalizations.of(context).terminatedStatus, 'Terminated', selectedTab),
            ],
          ),
        );
  }

  Widget _buildTabItem(String displayTitle, String value, String selectedTab) {
    final isSelected = selectedTab == value;
    return OrderTab(
      title: displayTitle,
      isSelected: isSelected,
      onTap: () => ref.read(selectedOrderTabProvider.notifier).state = value,
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
    // Use the preloaded user data
    final user = ref.read(ordersScreenUserProvider);
    
    if (user != null && user.isProfileComplete) {
      // Reset all order-related state before navigating to create screen
      ref.read(orderModelProvider.notifier).resetOrder();
      ref.read(customerDataProvider.notifier).state = null;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateOrderScreen(),
        ),
      ).then((_) => _fetchOrders());
    } else {
      // Profile is not complete, show toast message
      ToastService.show(
        context,
        'Please complete and activate your account first',
        type: ToastType.warning,
      );
    }
  }
}