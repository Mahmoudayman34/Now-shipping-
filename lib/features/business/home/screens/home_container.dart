import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/layout/main_layout.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../pickups/screens/pickups_screen.dart';
import '../../wallet/screens/wallet_screen.dart';
import '../../more/screens/more_screen.dart';

class HomeContainer extends ConsumerWidget {
  const HomeContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Defining all our main screens
    final screens = [
      const DashboardScreen(),
      const OrdersScreen(),
      const PickupsScreen(),
      const WalletScreen(),
      const MoreScreen(),
    ];
    
    // Use the main layout to handle navigation and floating action button
    return MainLayout(screens: screens);
  }
}