import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svg_flutter/svg.dart';
import '../providers/dashboard_provider.dart';

class DashboardBottomNav extends ConsumerWidget {
  const DashboardBottomNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);
    
    return Container(
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
          _buildNavItem(context, 0, 'assets/icons/home.png', 'Home', currentIndex, ref),
          _buildNavItem(context, 1, 'assets/icons/order.png', 'Orders', currentIndex, ref),
          _buildNavItem(context, 2, 'assets/icons/pickup.png', 'Pickups', currentIndex, ref),
          _buildNavItem(context, 3, 'assets/icons/wallet.png', 'Wallet', currentIndex, ref),
          _buildNavItem(context, 4, 'assets/icons/more.png', 'More', currentIndex, ref),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String? iconPath, String label, 
      int currentIndex, WidgetRef ref, {IconData? icon}) {
    final isSelected = currentIndex == index;
    
    return InkWell(
      onTap: () => ref.read(currentTabIndexProvider.notifier).state = index,
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
            child: icon != null
                ? Icon(
                    icon,
                    size: 26,
                    color: isSelected ? const Color(0xfff29620) : Colors.grey,
                  )
                : Image.asset(
                    iconPath!,
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
}