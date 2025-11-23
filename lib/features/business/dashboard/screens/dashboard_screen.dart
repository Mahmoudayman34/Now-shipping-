import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../auth/services/auth_service.dart';
import '../../../../core/layout/main_layout.dart' show layoutUserProvider;
import '../../../../features/business/services/user_service.dart' show userDataProvider;
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/welcome_message.dart';
import '../widgets/today_overview.dart';
import '../widgets/statistics_grid.dart';
import '../widgets/cash_summary.dart';
import '../widgets/new_orders_notification.dart';
import '../widgets/profile_completion_form.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/error_message_parser.dart';
import '../../../common/widgets/shimmer_loading.dart';
import '../../../../core/mixins/refreshable_screen_mixin.dart';
import '../../../../core/services/notification_permission_helper.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin, RefreshableScreenMixin {
  bool _isChecking = true;
  bool _isRefreshing = false;
  late AnimationController _rotationController;
  final ScrollController _scrollController = ScrollController();
  
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
      // Invalidate user providers to ensure fresh data on screen load
      ref.invalidate(currentUserProvider);
      ref.invalidate(layoutUserProvider);
      ref.invalidate(userDataProvider);
      // Initial data fetch
      _refreshDashboard();
      // Register refresh callback for tab tap refresh
      registerRefreshCallback(_refreshDashboard, 0);
      // Check notification permissions
      if (mounted) {
        NotificationPermissionHelper.checkPermissions(context);
      }
    });
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _scrollController.dispose();
    // Unregister refresh callback
    unregisterRefreshCallback(0);
    super.dispose();
  }
  
  Future<void> _checkProfileStatus() async {
    await ref.read(authServiceProvider).getCurrentUser();
    
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }
  
  Future<void> _refreshDashboard() async {
    // Only refresh if not already refreshing to prevent multiple simultaneous refreshes
    if (_isRefreshing) return;
    
    // Save current scroll position
    final currentScrollPosition = _scrollController.hasClients ? _scrollController.offset : 0.0;
    
    // Set refreshing state to true to show shimmer effect
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }
    
    try {
      // Create a list of futures to wait for both data fetching operations
      await Future.wait([
        // Refresh dashboard data
        ref.refresh(dashboardStatsProvider.future),
        // Also refresh user data to get updated name and other user information  
        ref.refresh(currentUserProvider.future),
        // Refresh layout user provider to update FAB visibility
        ref.refresh(layoutUserProvider.future),
      ]);
      
      // Refresh completed successfully
    } catch (e) {
      // Handle error
      
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
          if (mounted) {
            setState(() {
              _isRefreshing = false;
            });
            
            // Restore scroll position after refresh
            if (_scrollController.hasClients && currentScrollPosition > 0) {
              _scrollController.animateTo(
                currentScrollPosition,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            }
          }
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return _buildLoadingScreen(AppLocalizations.of(context).checkingProfileStatus);
    }
    
    final userAsyncValue = ref.watch(currentUserProvider);
    
    return userAsyncValue.when(
      data: (user) {
        if (user == null) {
          // Handle not logged in state
          return Scaffold(
            body: Center(child: Text(AppLocalizations.of(context).notLoggedIn)),
          );
        }
        
        // Check if profile is complete
        final isProfileComplete = user.isProfileComplete;
        
        // Build dashboard with appropriate content based on profile completion
        final bodyContent = isProfileComplete
            ? _buildCompleteDashboard(context, ref, user)
            : _buildProfileCompletionDashboard(context, user);

        return ResponsiveUtils.wrapScreen(
          body: bodyContent,
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
              Text('${AppLocalizations.of(context).error}: ${ErrorMessageParser.parseError(error)}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Trigger the refresh
                  ref.invalidate(currentUserProvider);
                },
                child: Text(AppLocalizations.of(context).retry),
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

  double _fabBottomPadding(BuildContext context) {
    final baseSpacing = ResponsiveUtils.getResponsiveSpacing(context);
    return MediaQuery.of(context).padding.bottom + baseSpacing * 6;
  }
 
  Widget _buildProfileCompletionDashboard(BuildContext context, UserModel user) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = ResponsiveUtils.getResponsivePadding(context);
        final spacing = ResponsiveUtils.getResponsiveSpacing(context);
        
        return Column(
          children: [
            // Header with logo and actions
            DashboardHeader(userName: user.fullName),
            
            // Welcome message for new users
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context).welcomeUser}, ${user.fullName}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 18,
                        tablet: 22,
                        desktop: 26,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing / 2),
                  Text(
                    AppLocalizations.of(context).completeProfile,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Profile completion form
            Expanded(
                child: const ProfileCompletionForm(),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildCompleteDashboard(BuildContext context, WidgetRef ref, UserModel user) {
    final dashboardStatsAsyncValue = ref.watch(dashboardStatsProvider);
    
    return dashboardStatsAsyncValue.when(
        data: (stats) {
          // Show shimmer loading when refreshing or display the actual content
          return _isRefreshing
              ? const Center(child: DashboardShimmer())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
                    
                    return CustomScrollView(
                      controller: _scrollController,
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
                              
                              SizedBox(height: spacing),
                              
                              // Suggestion box
                              //const SuggestionBox(),
                              
                              SizedBox(height: spacing + 8),
                              
                              // Today's overview
                              TodayOverview(
                                inHubPackages: stats.inHubPackages,
                              ),
                              
                              SizedBox(height: spacing + 8),
                              
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
                              
                              SizedBox(height: spacing + 8),
                              
                              // Cash summary
                              CashSummary(
                                expectedCash: stats.expectedCash,
                                collectedCash: stats.collectedCash,
                                collectionRate: stats.collectionRate,
                              ),
                              
                              SizedBox(height: spacing + 8),
                              
                              // New orders notification
                              NewOrdersNotification(newOrdersCount: stats.newOrders),
                              
                             // SizedBox(height: spacing + 8),
                              
                              // Detailed breakdown
                              //const DetailedBreakdown(),
                              
                              SizedBox(height: spacing * 2.5),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(height: _fabBottomPadding(context)),
                        ),
                      ],
                    );
                  },
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
      );
  }
}