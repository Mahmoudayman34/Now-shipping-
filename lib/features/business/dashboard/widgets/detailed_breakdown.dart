import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_model.dart';
import '../providers/dashboard_provider.dart';

class DetailedBreakdown extends ConsumerWidget {
  const DetailedBreakdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(detailedBreakdownTabProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.dashboard, size: 20, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                "Detailed Breakdown",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildBreakdownChip(
                  context, 
                  ref,
                  "Awaiting Action (0)", 
                  DetailedBreakdownTab.awaitingAction, 
                  selectedTab == DetailedBreakdownTab.awaitingAction
                ),
                const SizedBox(width: 12),
                _buildBreakdownChip(
                  context, 
                  ref,
                  "Heading To Customer (0)", 
                  DetailedBreakdownTab.headingToCustomer,
                  selectedTab == DetailedBreakdownTab.headingToCustomer
                ),
                const SizedBox(width: 12),
                _buildBreakdownChip(
                  context, 
                  ref,
                  "Pickup (0)", 
                  DetailedBreakdownTab.pickup,
                  selectedTab == DetailedBreakdownTab.pickup
                ),
              ],
            ),
          ),
          // Here you would add the content for the selected tab
          const SizedBox(height: 16),
          _buildTabContent(selectedTab),
        ],
      ),
    );
  }

  Widget _buildBreakdownChip(BuildContext context, WidgetRef ref, String label, DetailedBreakdownTab tab, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(detailedBreakdownTabProvider.notifier).state = tab;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.teal) : null,
        ),
        child: Row(
          children: [
            _getTabIcon(tab, isSelected, 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.teal : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _getTabIcon(DetailedBreakdownTab tab, bool isSelected, double size) {
    String iconPath;
    switch (tab) {
      case DetailedBreakdownTab.awaitingAction:
        iconPath = 'assets/icons/wating.png';
        break;
      case DetailedBreakdownTab.headingToCustomer:
        iconPath = 'assets/icons/to_customer.png';
        
        break;
      case DetailedBreakdownTab.pickup:
        iconPath = 'assets/icons/pickup.png';
        break;
    }
    
    return Image.asset(
      iconPath,
      width: size,
      height: size,
      color: isSelected ? Colors.teal : Colors.grey,
    );
  }
  
  Widget _buildTabContent(DetailedBreakdownTab selectedTab) {
    // This would be replaced with actual content for each tab
    switch (selectedTab) {
      case DetailedBreakdownTab.awaitingAction:
        return const Center(
          child: Text('No orders awaiting action'),
        );
      case DetailedBreakdownTab.headingToCustomer:
        return const Center(
          child: Text('No orders heading to customers'),
        );
      case DetailedBreakdownTab.pickup:
        return const Center(
          child: Text('No pickup orders'),
        );
    }
  }
}