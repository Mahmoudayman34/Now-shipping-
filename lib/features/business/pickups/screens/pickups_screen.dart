import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:now_shipping/core/widgets/toast_.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import 'package:now_shipping/features/business/pickups/models/pickup_model.dart';
import 'package:now_shipping/features/business/pickups/providers/pickup_provider.dart';
import 'package:now_shipping/features/business/pickups/screens/create_pickup_screen.dart';
import 'package:now_shipping/features/business/pickups/screens/pickup_details_screen.dart';
import 'package:now_shipping/features/business/pickups/widgets/pickup_card.dart';
import 'package:now_shipping/features/common/widgets/shimmer_loading.dart';

// Provider to store cached user data for this screen
final pickupsScreenUserProvider = StateProvider<UserModel?>((ref) => null);

class PickupsScreen extends ConsumerStatefulWidget {
  const PickupsScreen({super.key});

  @override
  ConsumerState<PickupsScreen> createState() => _PickupsScreenState();
}

class _PickupsScreenState extends ConsumerState<PickupsScreen> with SingleTickerProviderStateMixin {
  String _selectedTab = 'Upcoming';
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late AnimationController _rotationController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Initialize the rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(); // Makes it rotate continuously
    
    // Preload user data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadUserData();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  // Preload user data to avoid delay when creating pickups
  Future<void> _preloadUserData() async {
    final authService = ref.read(authServiceProvider);
    final user = await authService.getCurrentUser();
    
    // Store in the provider for later use
    ref.read(pickupsScreenUserProvider.notifier).state = user;
  }
  
  void _onRefresh() async {
    // Set refreshing state
    setState(() {
      _isRefreshing = true;
    });
    
    // Refresh pickups data based on selected tab
    if (_selectedTab == 'Upcoming') {
      ref.invalidate(upcomingPickupsProvider);
    } else {
      ref.invalidate(completedPickupsProvider);
    }
    
    // Wait a bit for the data to load and then complete refresh
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _isRefreshing = false;
    });
    
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the pickups data based on selected tab
    final pickupsAsync = _selectedTab == 'Upcoming' 
        ? ref.watch(upcomingPickupsProvider)
        : ref.watch(completedPickupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickups'),
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
                    'Upcoming',
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
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.refresh, color: Color(0xFFFF9800), size: 24),
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
              child: pickupsAsync.when(
                data: (pickups) {
                  // Show shimmer if we're refreshing
                  if (_isRefreshing) {
                    return _buildLoadingState();
                  }
                  
                  if (pickups.isNotEmpty) {
                    return ListView.builder(
                      itemCount: pickups.length,
                      itemBuilder: (context, index) {
                        final pickup = pickups[index];
                        return PickupCard(
                          pickup: pickup,
                          onTap: () {
                            _showPickupActions(context, pickup);
                          },
                        );
                      },
                    );
                  } else {
                    return _buildEmptyState();
                  }
                },
                loading: () => _buildLoadingState(),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load pickups',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => refreshPickups(ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
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

  Widget _buildPickupTab(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title == 'History' ? 'History' : 'Upcoming';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5F8F9) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFFFF9800)) : Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFF9800) : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
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
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/icon_only.png', 
            width: 100,
            height: 100,
            color: Colors.grey[300],
            errorBuilder: (context, error, stackTrace) => 
                Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedTab == 'Upcoming' 
                ? 'No upcoming pickups'
                : 'No pickup history',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedTab == 'Upcoming'
                ? 'Create your first pickup to get started'
                : 'Completed pickups will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_selectedTab == 'Upcoming')
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
                onPressed: () {
                  // Use the preloaded user data
                  final user = ref.read(pickupsScreenUserProvider);
                  
                  if (user != null && user.isProfileComplete) {
                    // Profile is complete, proceed with navigation
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePickupScreen(),
                      ),
                    ).then((_) {
                      // Refresh pickups after creating a new one
                      refreshPickups(ref);
                    });
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
                      'Pickup #${pickup.pickupNumber}',
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
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupDetailsScreen(pickup: pickup),
                    ),
                  );
                  
                  // Refresh pickups after viewing details
                  refreshPickups(ref);
                },
              ),
                            
              if (pickup.status == 'Upcoming')
              _buildActionItem(
                icon: Icons.edit_outlined,
                title: 'Edit Pickup',
                onTap: () async {
                  Navigator.pop(context);
                  // Navigate to CreatePickupScreen with the pickup data for editing
                    await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePickupScreen(pickupToEdit: pickup),
                    ),
                  );
                  
                    // Refresh pickups after editing
                    refreshPickups(ref);
                  },
                ),
              
              if (pickup.status == 'Upcoming')
              _buildActionItem(
                icon: Icons.delete_outline,
                  title: 'Cancel Pickup',
                titleColor: Colors.red,
                backgroundColor: const Color(0xFFFEE8E8),
                onTap: () {
                  Navigator.pop(context);
                    _showCancelConfirmation(context, pickup);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelConfirmation(BuildContext context, PickupModel pickup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Pickup'),
        content: Text(
          'Are you sure you want to cancel pickup #${pickup.pickupNumber}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel pickup API call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pickup cancellation feature coming soon'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
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