import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/core/widgets/toast_.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import 'package:now_shipping/features/business/pickups/models/pickup_model.dart';
import 'package:now_shipping/features/business/pickups/screens/create_pickup_screen.dart';
import 'package:now_shipping/features/business/pickups/screens/pickup_details_screen.dart';
import 'package:now_shipping/features/business/pickups/widgets/pickup_card.dart';
import 'package:intl/intl.dart';

class PickupsScreen extends StatefulWidget {
  const PickupsScreen({super.key});

  @override
  State<PickupsScreen> createState() => _PickupsScreenState();
}

class _PickupsScreenState extends State<PickupsScreen> {
  String _selectedTab = 'Upcoming';
  
  // Sample pickup data
  final List<PickupModel> _pickups = [
    PickupModel(
      pickupId: '10001',
      address: 'Cairo, Maadi, Street 9',
      contactNumber: '+201234567890',
      pickupDate: DateTime.now().add(const Duration(days: 1)),
      status: 'Upcoming',
      isFragileItem: true,
      notes: 'Please handle with care',
    ),
    PickupModel(
      pickupId: '10002',
      address: 'Cairo, Heliopolis, Triumph Square',
      contactNumber: '+201234567891',
      pickupDate: DateTime.now().add(const Duration(days: 2)),
      status: 'Upcoming',
      isLargeItem: true,
      notes: 'Large furniture item',
    ),
    PickupModel(
      pickupId: '10003',
      address: 'Cairo, Downtown, Tahrir Square',
      contactNumber: '+201234567892',
      pickupDate: DateTime.now().subtract(const Duration(days: 2)),
      status: 'Picked Up',
      notes: 'Electronics',
    ),
    PickupModel(
      pickupId: '10004',
      address: 'Cairo, New Cairo, 5th Settlement',
      contactNumber: '+201234567893',
      pickupDate: DateTime.now().subtract(const Duration(days: 5)),
      status: 'Picked Up',
      isFragileItem: true,
      isLargeItem: true,
      notes: 'Large glass table',
    ),
  ];
  
  // Filtered pickups based on selected tab
  List<PickupModel> get _filteredPickups {
    return _pickups.where((pickup) => 
      (_selectedTab == 'Upcoming' && pickup.status == 'Upcoming') ||
      (_selectedTab == 'History' && pickup.status == 'Picked Up')
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar for Pickups categories
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildPickupTab(
                    'Upcoming (${_pickups.where((p) => p.status == 'Upcoming').length})',
                    _selectedTab == 'Upcoming',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPickupTab(
                    'History', 
                    _selectedTab == 'History',
                  ),
                ),
              ],
            ),
          ),
          
          // Pickup list or empty state
          Expanded(
            child: _filteredPickups.isNotEmpty
              ? ListView.builder(
                  itemCount: _filteredPickups.length,
                  itemBuilder: (context, index) {
                    final pickup = _filteredPickups[index];
                    return PickupCard(
                      pickup: pickup,
                      onTap: () {
                        // Navigate to pickup details screen when implemented
                        _showPickupActions(context, pickup);
                      },
                    );
                  },
                )
              : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupTab(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title.contains('Upcoming') ? 'Upcoming' : 'History';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5F8F9) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00ADB5) : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
final ref = ProviderScope.containerOf(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/icon_only.png', 
            width: 100,
            height: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'You didn\'t create pickups yet!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
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
                onPressed: () async {
                  // Check if user profile is complete before navigating
                  final authService = ref.read(authServiceProvider);
                  final user = await authService.getCurrentUser();
                  
                  if (user != null && user.isProfileComplete) {
                    // Profile is complete, proceed with navigation
                    // Navigate to pickup creation screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePickupScreen(),
                      ),
                    );
                  } else {
                    // Profile is not complete, show toast message
                    ToastService.show(
                      context,
                      'Please complete and activate your account first',
                      type: ToastType.warning,
                    );
                  }
                },
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
                        'Create Pickup',
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

  void _showPickupActions(BuildContext context, PickupModel pickup) {
    // Show bottom sheet with pickup actions
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Pickup #${pickup.pickupId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2F2F2F),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              
              // Action items
              _buildActionItem(
                icon: Icons.visibility_outlined,
                title: 'View Details',
                onTap: () async {
                  Navigator.pop(context);
                  // Navigate to Pickup Details screen
                  final updatedPickup = await Navigator.push<PickupModel>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupDetailsScreen(pickup: pickup),
                    ),
                  );
                  
                  // Update the pickup if changes were made
                  if (updatedPickup != null) {
                    setState(() {
                      final index = _pickups.indexWhere((p) => p.pickupId == pickup.pickupId);
                      if (index != -1) {
                        _pickups[index] = updatedPickup;
                      }
                    });
                  }
                },
              ),
                            
              _buildActionItem(
                icon: Icons.edit_outlined,
                title: 'Edit Pickup',
                onTap: () async {
                  Navigator.pop(context);
                  // Navigate to CreatePickupScreen with the pickup data for editing
                  final updatedPickup = await Navigator.push<PickupModel>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePickupScreen(pickupToEdit: pickup),
                    ),
                  );
                  
                  // Update the pickup if changes were made
                  if (updatedPickup != null) {
                    setState(() {
                      final index = _pickups.indexWhere((p) => p.pickupId == pickup.pickupId);
                      if (index != -1) {
                        _pickups[index] = updatedPickup;
                      }
                    });
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pickup updated successfully')),
                    );
                  }
                },
              ),
              
              _buildActionItem(
                icon: Icons.delete_outline,
                title: 'Delete Pickup',
                titleColor: Colors.red,
                backgroundColor: const Color(0xFFFEE8E8),
                onTap: () {
                  Navigator.pop(context);
                  // Handle delete pickup
                  setState(() {
                    _pickups.removeWhere((p) => p.pickupId == pickup.pickupId);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildActionItem({
    required IconData icon,
    required String title,
    Color? titleColor,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: backgroundColor ?? Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? const Color(0xFF26A2B9)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: titleColor ?? const Color(0xff2F2F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}