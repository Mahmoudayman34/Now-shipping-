import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/services/auth_service.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/welcome_message.dart';
import '../widgets/today_overview.dart';
import '../widgets/statistics_grid.dart';
import '../widgets/cash_summary.dart';
import '../widgets/new_orders_notification.dart';
import '../widgets/profile_completion_form.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../common/widgets/shimmer_loading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  bool _isChecking = true;
  bool _isProfileComplete = false;
  bool _isRefreshing = false;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late AnimationController _rotationController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize the rotation animation controller for the refresh icon
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(); // Makes it rotate continuously
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileStatus();
      // Initial data fetch
      _refreshDashboard();
    });
  }
  
  @override
  void dispose() {
    _refreshController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  Future<void> _checkProfileStatus() async {
    final user = await ref.read(authServiceProvider).getCurrentUser();
    
    if (mounted) {
      setState(() {
        _isChecking = false;
        _isProfileComplete = user?.isProfileComplete ?? false;
      });
    }
  }
  
  Future<void> _refreshDashboard() async {
    // Set refreshing state to true to show shimmer effect
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }
    
    try {
      // Create a list of futures to wait for both data fetching operations
      final futures = await Future.wait([
        // Refresh dashboard data
        ref.refresh(dashboardStatsProvider.future),
        // Also refresh user data to get updated name and other user information  
        ref.refresh(currentUserProvider.future),
      ]);
      
      // If successful, complete the refresh
      if (_refreshController.isRefresh) {
        _refreshController.refreshCompleted();
      }
    } catch (e) {
      // If there's an error, show the fail indicator
      if (_refreshController.isRefresh) {
        _refreshController.refreshFailed();
      }
      
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Internet connection issue'),
                const Spacer(),
                TextButton(
                  onPressed: _refreshDashboard,
                  child: const Text('RETRY', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // Only reset refreshing state after all data fetching is completed
      if (mounted) {
        // Give a slight delay to ensure UI updates completely
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _isRefreshing = false;
          });
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return _buildLoadingScreen("Checking profile status...");
    }
    
    final userAsyncValue = ref.watch(currentUserProvider);
    
    return userAsyncValue.when(
      data: (user) {
        if (user == null) {
          // Handle not logged in state
          return const Scaffold(
            body: Center(child: Text('Not logged in')),
          );
        }
        
        // Check if profile is complete
        final isProfileComplete = user.isProfileComplete;
        
        // Build dashboard with appropriate content based on profile completion
        return ResponsiveUtils.wrapScreen(
          body: isProfileComplete 
            ? _buildCompleteDashboard(context, ref, user)
            : _buildProfileCompletionDashboard(context, user),
          // Removed bottomNavigationBar and floatingActionButton since they're now handled by MainLayout
        );
      },
      loading: () => _buildLoadingScreen(""),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Ignore the unused result intentionally - we just want to trigger the refresh
                  ref.refresh(currentUserProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ShimmerContainer(
              width: 100,
              height: 100,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileCompletionDashboard(BuildContext context, UserModel user) {
    return Column(
      children: [
        // Header with logo and actions
        DashboardHeader(userName: user.fullName),
        
        // Welcome message for new users
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user.fullName}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please complete your profile to access all features',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        
        // Profile completion form
        const Expanded(
          child: ProfileCompletionForm(),
        ),
      ],
    );
  }
  
  Widget _buildCompleteDashboard(BuildContext context, WidgetRef ref, UserModel user) {
    final dashboardStatsAsyncValue = ref.watch(dashboardStatsProvider);
    
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _refreshDashboard,
      enablePullDown: true,
      enablePullUp: false,
      physics: const ClampingScrollPhysics(),
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
      child: dashboardStatsAsyncValue.when(
        data: (stats) {
          // Show shimmer loading when refreshing or display the actual content
          return _isRefreshing
              ? const Center(child: DashboardShimmer())
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with logo and actions
                          DashboardHeader(userName: user.fullName),
                          
                          // Welcome message
                          WelcomeMessage(name: user.fullName),
                          
                          const SizedBox(height: 16),
                          
                          // Suggestion box
                          //const SuggestionBox(),
                          
                          const SizedBox(height: 20),
                          
                          // Today's overview
                          TodayOverview(
                            inHubPackages: stats.inHubPackages,
                          ),
                          
                          // Statistics grid
                          StatisticsGrid(
                            headingToCustomer: stats.headingToCustomer,
                            awaitingAction: stats.awaitingAction,
                            successfulOrders: stats.successfulOrders,
                            unsuccessfulOrders: stats.unsuccessfulOrders,
                            headingToYou: stats.headingToYou,
                            newOrders: stats.newOrders,
                            successRate: stats.successRate,
                            unsuccessRate: stats.unsuccessRate,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Cash summary
                          CashSummary(
                            expectedCash: stats.expectedCash,
                            collectedCash: stats.collectedCash,
                            collectionRate: stats.collectionRate,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // New orders notification
                          NewOrdersNotification(newOrdersCount: stats.newOrders),
                          
                         // const SizedBox(height: 20),
                          
                          // Detailed breakdown
                          //const DetailedBreakdown(),
                          
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                );
        },
        loading: () => const Center(
          child: DashboardShimmer(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Internet connection issue'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshDashboard,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
                    icon: const Icon(Icons.close, color: Color(0xfff29620)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  // Handle create single order action
                  Navigator.pop(context);
                  // Navigate to order creation screen
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
                onTap: () {
                  // Handle schedule pickup action
                  Navigator.pop(context);
                  // Navigate to pickup scheduling screen
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