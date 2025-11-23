import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/pickups/screens/pickup_details_tabbed_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'package:now_shipping/core/widgets/toast_.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import 'package:now_shipping/features/business/pickups/models/pickup_model.dart';
import 'package:now_shipping/features/business/pickups/providers/pickup_provider.dart';
import 'package:now_shipping/features/business/pickups/screens/create_pickup_screen.dart';

import 'package:now_shipping/features/business/pickups/widgets/pickup_card.dart';
import 'package:now_shipping/features/common/widgets/shimmer_loading.dart';
import '../../../../core/mixins/refreshable_screen_mixin.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/error_message_parser.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provider to store cached user data for this screen
final pickupsScreenUserProvider = StateProvider<UserModel?>((ref) => null);

class PickupsScreen extends ConsumerStatefulWidget {
  const PickupsScreen({super.key});

  @override
  ConsumerState<PickupsScreen> createState() => _PickupsScreenState();
}

class _PickupsScreenState extends ConsumerState<PickupsScreen> with SingleTickerProviderStateMixin, RefreshableScreenMixin {
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
      // Register refresh callback for tab tap refresh
      registerRefreshCallback(_onRefresh, 2);
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _rotationController.dispose();
    // Unregister refresh callback
    unregisterRefreshCallback(2);
    super.dispose();
  }
  
  // Preload user data to avoid delay when creating pickups
  Future<void> _preloadUserData() async {
    final authService = ref.read(authServiceProvider);
    final user = await authService.getCurrentUser();
    
    // Store in the provider for later use
    ref.read(pickupsScreenUserProvider.notifier).state = user;
  }
  
  double _fabBottomPadding(BuildContext context) {
    final baseSpacing = ResponsiveUtils.getResponsiveSpacing(context);
    return MediaQuery.of(context).padding.bottom + baseSpacing * 6;
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

    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context).pickups,
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
        ),
        body: Column(
          children: [
            // Tab bar for Pickups categories
            _buildTabBar(),
            
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
                        errorBuilder: (context, error, stackTrace) => 
                            Icon(
                              Icons.refresh,
                              color: const Color(0xFFFF9800),
                              size: ResponsiveUtils.getResponsiveIconSize(context),
                            ),
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
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  idleText: AppLocalizations.of(context).pullDownToRefresh,
                  releaseText: AppLocalizations.of(context).releaseToRefresh,
                  refreshingText: AppLocalizations.of(context).refreshingText,
                  completeText: AppLocalizations.of(context).refreshCompleted,
                  failedText: AppLocalizations.of(context).refreshFailedText,
                ),
                child: pickupsAsync.when(
                  data: (pickups) {
                    // Show shimmer if we're refreshing
                    if (_isRefreshing) {
                      return _buildLoadingState();
                    }
                    
                    if (pickups.isNotEmpty) {
                      final bottomPadding = _fabBottomPadding(context);
                      final topPadding = ResponsiveUtils.getResponsiveSpacing(context);
                      return ListView.builder(
                        padding: EdgeInsets.only(
                          bottom: bottomPadding,
                          top: topPadding,
                        ),
                        itemCount: pickups.length,
                        itemBuilder: (context, index) {
                          final pickup = pickups[index];
                          return PickupCard(
                            pickup: pickup,
                            onTap: () {
                              _showPickupActions(context, pickup);
                            },
                            onDelete: () {
                              _deletePickup(context, pickup);
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
                          size: ResponsiveUtils.getResponsiveIconSize(context) * 3,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                        Text(
                          AppLocalizations.of(context).failedToLoadPickups,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 18,
                              tablet: 20,
                              desktop: 22,
                            ),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 0.5),
                        Padding(
                          padding: ResponsiveUtils.getResponsiveHorizontalPadding(context),
                          child: Text(
                            error.toString(),
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                        ElevatedButton(
                          onPressed: () => refreshPickups(ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.getResponsiveSpacing(context) * 2,
                              vertical: ResponsiveUtils.getResponsiveSpacing(context),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).retry,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildTabBar() {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final horizontalPadding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.horizontal / 2,
        vertical: spacing,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPickupTab(
              AppLocalizations.of(context).upcoming,
              _selectedTab == 'Upcoming',
            ),
          ),
          SizedBox(width: spacing * 0.67),
          Expanded(
            child: _buildPickupTab(
              AppLocalizations.of(context).history,
              _selectedTab == 'History',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupTab(String title, bool isSelected) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          // Check if this is the history tab by comparing with localized text
          _selectedTab = title == AppLocalizations.of(context).history ? 'History' : 'Upcoming';
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: spacing),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5F8F9) : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isSelected
              ? Border.all(color: const Color(0xFFFF9800))
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFF9800) : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingState() {
    final bottomPadding = _fabBottomPadding(context);
    return ListView.builder(
      padding: EdgeInsets.only(bottom: bottomPadding),
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
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final imageSize = ResponsiveUtils.getResponsiveImageSize(context) * 2;
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: _fabBottomPadding(context)),
      child: Center(
        child: Padding(
          padding: ResponsiveUtils.getResponsiveHorizontalPadding(context),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/icon_only.png',
              width: imageSize,
              height: imageSize,
              color: Colors.grey[300],
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.inventory_2_outlined,
                size: imageSize,
                color: Colors.grey.shade300,
              ),
            ),
            SizedBox(height: spacing * 2),
            Text(
              _selectedTab == 'Upcoming'
                  ? AppLocalizations.of(context).noUpcomingPickups
                  : AppLocalizations.of(context).noPickupHistory,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: spacing * 0.67),
            Text(
              _selectedTab == 'Upcoming'
                  ? AppLocalizations.of(context).createFirstPickup
                  : AppLocalizations.of(context).completedPickupsHere,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing * 2.67),
            if (_selectedTab == 'Upcoming')
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius * 2),
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
                      borderRadius: BorderRadius.circular(borderRadius * 2),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF6D00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(borderRadius * 2),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing * 2.33,
                        vertical: spacing * 1.17,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            size: ResponsiveUtils.getResponsiveIconSize(context) * 1.1,
                          ),
                          SizedBox(width: spacing * 0.67),
                          Text(
                            AppLocalizations.of(context).createPickup,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 16,
                                tablet: 18,
                                desktop: 20,
                              ),
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
        ),
      ),
    );
  }

  void _showPickupActions(BuildContext context, PickupModel pickup) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    // Show bottom sheet with pickup actions
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius * 2)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: spacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Row(
                  children: [
                    Text(
                      '${AppLocalizations.of(context).pickupNumber}${pickup.pickupNumber}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff2F2F2F),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: ResponsiveUtils.getResponsiveIconSize(context),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              
              // Action items
              _buildActionItem(
                icon: Icons.visibility_outlined,
                title: AppLocalizations.of(context).viewDetails,
                onTap: () async {
                  Navigator.pop(context);
                  // Navigate to Pickup Details screen
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupDetailsTabbedScreen(pickup: pickup),
                    ),
                  );
                  
                  // Refresh pickups after viewing details
                  refreshPickups(ref);
                },
              ),
                            
              if (pickup.status == 'Upcoming')
              _buildActionItem(
                icon: Icons.edit_outlined,
                title: AppLocalizations.of(context).editPickup,
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
                  title: AppLocalizations.of(context).cancelPickup,
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
    AppDialog.show(
      context,
      title: AppLocalizations.of(context).cancelPickup,
      message: AppLocalizations.of(context).cancelPickupConfirmation.replaceAll('#{number}', '#${pickup.pickupNumber}'),
      confirmText: AppLocalizations.of(context).yesCancel,
      cancelText: AppLocalizations.of(context).cancel,
      confirmColor: Colors.red,
    ).then((confirmed) {
      if (confirmed == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).pickupCancellationFeatureComingSoon),
          ),
        );
      }
    });
  }

  void _deletePickup(BuildContext context, PickupModel pickup) {
    AppDialog.show(
      context,
      title: AppLocalizations.of(context).deletePickup,
      message: AppLocalizations.of(context).deletePickupConfirmation.replaceAll('#{number}', '#${pickup.pickupNumber}'),
      confirmText: AppLocalizations.of(context).yesDelete,
      cancelText: AppLocalizations.of(context).cancel,
      confirmColor: Colors.red,
    ).then((confirmed) async {
      if (confirmed == true) {
        try {
          // Get the pickup repository
          final repository = ref.read(pickupRepositoryProvider);
          
          // Delete the pickup
          final success = await repository.deletePickup(pickup.pickupNumber);
          
          if (success) {
            // Show success message and refresh the list
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).pickupDeletedSuccessfully),
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              );
              // Refresh pickups list
              refreshPickups(ref);
            }
          } else {
            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).failedToDeletePickup),
                  backgroundColor: const Color(0xFFE53E3E),
                ),
              );
            }
          }
        } catch (e) {
          // Show user-friendly error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ErrorMessageParser.parseError(e)),
                backgroundColor: const Color(0xFFE53E3E),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    });
  }
  
  Widget _buildActionItem({
    required IconData icon,
    required String title,
    Color? titleColor,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: spacing,
          horizontal: spacing,
        ),
        color: backgroundColor ?? Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              color: titleColor ?? const Color(0xFF26A2B9),
              size: ResponsiveUtils.getResponsiveIconSize(context),
            ),
            SizedBox(width: spacing),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                color: titleColor ?? const Color(0xff2F2F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}