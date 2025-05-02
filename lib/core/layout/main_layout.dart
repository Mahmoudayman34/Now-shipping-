import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/features/business/dashboard/screens/dashboard_screen.dart';
import 'package:tes1/features/auth/services/auth_service.dart'; 
import 'package:tes1/core/widgets/toast_.dart'; 
import 'package:tes1/features/business/orders/screens/create_order/create_order_screen.dart';
import 'package:tes1/features/business/pickups/screens/create_pickup_screen.dart';

// Provider to manage the selected tab index
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

class MainLayout extends ConsumerWidget {
  final List<Widget> screens;
  
  const MainLayout({
    super.key,
    required this.screens,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabIndexProvider);
    
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, selectedIndex, ref),
      floatingActionButton: _shouldShowFAB(selectedIndex) 
          ? FloatingActionButton(
              onPressed: () {
               _showCreateOptionsBottomSheet(context);
              },
              backgroundColor: const Color(0xfff29620),
              child: const Icon(Icons.add, color: Colors.white),
            ) 
          : null,
    );
  }
  
  // Determine if the FAB should be shown based on the selected tab
  bool _shouldShowFAB(int index) {
    // Show FAB only on Home (0), Orders (1), and Pickups (2) screens
    return index == 0 || index == 1 || index == 2;
  }
  
  Widget _buildBottomNavigationBar(BuildContext context, int selectedIndex, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.transparent.withOpacity(0),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          color: Colors.white,
        ),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, 'assets/icons/home.png', 'Home', selectedIndex, ref),
            _buildNavItem(context, 1, 'assets/icons/order.png', 'Orders', selectedIndex, ref),
            _buildNavItem(context, 2, 'assets/icons/pickup.png', 'Pickups', selectedIndex, ref),
            _buildNavItem(context, 3, 'assets/icons/wallet.png', 'Wallet', selectedIndex, ref),
            _buildNavItem(context, 4, 'assets/icons/more.png', 'More', selectedIndex, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String iconPath, String label, 
      int selectedIndex, WidgetRef ref) {
    final isSelected = selectedIndex == index;
    
    return InkWell(
      onTap: () => ref.read(selectedTabIndexProvider.notifier).state = index,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selector shape that appears above the active icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: isSelected ? 30 : 0,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: const Color(0xfff29620),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Icon
          SizedBox(
            height: 26,
            width: 26,
            child: Image.asset(
              iconPath,
              width: 26,
              height: 26,
              color: isSelected ? const Color(0xfff29620) : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xfff29620) : Colors.grey,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showCreateOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final ref = ProviderScope.containerOf(context);
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 130.0),
                    child: Text(
                      'Create',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2F2F2F),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xff2F2F2F)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InkWell(
                onTap: () async {
                  // Check if user profile is complete before navigating
                  final authService = ref.read(authServiceProvider);
                  final user = await authService.getCurrentUser();
                  
                  if (user != null && user.isProfileComplete) {
                    // Profile is complete, proceed with navigation
                    Navigator.pop(context);
                    // Navigate to order creation screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateOrderScreen(),
                      ),
                    );
                  } else {
                    // Profile is not complete, show toast message
                    Navigator.pop(context);
                    ToastService.show(
                      context,
                      'Please complete and activate your account first',
                      type: ToastType.warning,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(120, 233, 233, 233),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/order.png',
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Single Order',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff2F2F2F),
                              ),
                            ),
                            SizedBox(height: 0.5),
                            Text(
                              'Create orders one by one.',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InkWell(
                onTap: () async {
                  // Check if user profile is complete before navigating
                  final authService = ref.read(authServiceProvider);
                  final user = await authService.getCurrentUser();
                  
                  if (user != null && user.isProfileComplete) {
                    // Profile is complete, proceed with navigation
                    Navigator.pop(context);
                    // Navigate to pickup creation screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePickupScreen(),
                      ),
                    );
                  } else {
                    // Profile is not complete, show toast message
                    Navigator.pop(context);
                    ToastService.show(
                      context,
                      'Please complete and activate your account first',
                      type: ToastType.warning,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(120, 233, 233, 233),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/pickup.png',
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Schedule Pickup',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff2F2F2F),
                              ),
                            ),
                            SizedBox(height: 0.5),
                            Text(
                              'Request a pickup to pick your orders.',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}