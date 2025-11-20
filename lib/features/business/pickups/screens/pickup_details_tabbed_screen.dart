import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:now_shipping/features/business/pickups/models/pickup_model.dart';
import 'package:now_shipping/features/business/pickups/providers/pickup_provider.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/l10n/app_localizations.dart';

class PickupDetailsTabbedScreen extends ConsumerStatefulWidget {
  final PickupModel pickup;

  const PickupDetailsTabbedScreen({
    super.key,
    required this.pickup,
  });

  @override
  ConsumerState<PickupDetailsTabbedScreen> createState() => _PickupDetailsTabbedScreenState();
}

class _PickupDetailsTabbedScreenState extends ConsumerState<PickupDetailsTabbedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Search controller for Orders Picked tab
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deletePickup),
          content: Text(l10n.deletePickupConfirmation.replaceAll('{number}', widget.pickup.pickupNumber)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePickup(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  // Delete pickup
  Future<void> _deletePickup(BuildContext context) async {
    try {
      // Get the pickup repository
      final repository = ref.read(pickupRepositoryProvider);
      
      // Delete the pickup
      final success = await repository.deletePickup(widget.pickup.pickupNumber);
      
      if (success) {
        // Show success message and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pickup deleted successfully'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate deletion
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete pickup. Please try again.'),
              backgroundColor: Color(0xFFE53E3E),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Pickup #${widget.pickup.pickupNumber}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xff2F2F2F),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: const Color(0xff2F2F2F),
              size: ResponsiveUtils.getResponsiveIconSize(context),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFFF6B35),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: const Color(0xFFFF6B35),
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: AppLocalizations.of(context).tracking),
              Tab(text: AppLocalizations.of(context).pickupDetails),
              Tab(text: AppLocalizations.of(context).ordersPicked),
            ],
          ),
        ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tracking Tab
          _buildTrackingTab(),
          
          // Pickup Details Tab - Use the existing details screen
          _buildPickupDetailsTab(),
          
          // Orders Picked Tab
          _buildOrdersPickedTab(),
        ],
      ),
      ),
    );
  }

  Widget _buildTrackingTab() {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Professional Header with Orange Gradient
            _buildProfessionalHeader(spacing, borderRadius),
            SizedBox(height: spacing * 2),
            _buildTrackingTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalHeader(double spacing, double borderRadius) {
    final completedStages = widget.pickup.pickupStages.length;
    final totalStages = 4; // Expected stages: Created, Assigned, Picked Up, Completed
    
    return Container(
            width: double.infinity,
      padding: EdgeInsets.all(spacing * 1.5),
            decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFE55A2B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
              borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                ),
                SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                      AppLocalizations.of(context).pickupTracking,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                    ),
                    fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).ofMilestonesCompleted
                          .replaceAll('{completed}', '$completedStages')
                          .replaceAll('{total}', '$totalStages'),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                        color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${widget.pickup.pickupNumber}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF6B35),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildTrackingTimeline() {
    final pickupStages = widget.pickup.pickupStages;
    
    // Define the expected stages in order with orange theme
    final expectedStages = [
      {'name': 'Pickup Created', 'icon': Icons.inventory_2_outlined, 'color': const Color(0xFFFF6B35)},
      {'name': 'driverAssigned', 'icon': Icons.person_outline, 'color': const Color(0xFFFF6B35)},
      {'name': 'pickedUp', 'icon': Icons.shopping_bag_outlined, 'color': const Color(0xFFFF6B35)},
      {'name': 'completed', 'icon': Icons.check_circle_outline, 'color': const Color(0xFFFF6B35)},
    ];
    
    return Column(
      children: expectedStages.asMap().entries.map((entry) {
        final index = entry.key;
        final expectedStage = entry.value;
        final isFirst = index == 0;
        final isLast = index == expectedStages.length - 1;
        
        // Find matching stage from API data
        final apiStage = pickupStages.firstWhere(
          (stage) => stage.stageName.toLowerCase() == expectedStage['name'].toString().toLowerCase(),
          orElse: () => PickupStage(
            id: '',
            stageName: expectedStage['name'] as String,
            stageDate: DateTime.now(), // Dummy date, will be checked as null
            stageNotes: [],
          ),
        );
        
        // Determine status based on whether stage exists and has a date
        String status;
        String displayTime = '--:--';
        String displayDate = '--/--/----';
        bool stageExists = pickupStages.any((stage) => 
          stage.stageName.toLowerCase() == expectedStage['name'].toString().toLowerCase()
        );
        
        final l10n = AppLocalizations.of(context);
        if (stageExists) {
          status = l10n.completed;
          final stageDateTime = apiStage.stageDate;
          displayTime = '${stageDateTime.hour.toString().padLeft(2, '0')}:${stageDateTime.minute.toString().padLeft(2, '0')}:${stageDateTime.second.toString().padLeft(2, '0')}';
          displayDate = '${stageDateTime.day}/${stageDateTime.month}/${stageDateTime.year}';
        } else {
          // Check if this stage should be "In Progress" (next expected stage)
          final previousStageCompleted = index == 0 || expectedStages.take(index).every((prevStage) {
            return pickupStages.any((stage) => 
              stage.stageName.toLowerCase() == prevStage['name'].toString().toLowerCase()
            );
          });
          
          status = previousStageCompleted && index < expectedStages.length - 1 ? l10n.inProgress : l10n.pending;
        }
        
        // Get display name
        String displayName = _getDisplayStageName(expectedStage['name'] as String);
        
        // Always use localized descriptions instead of API notes
        List<String> noteTexts = [];
        
        if (stageExists) {
          switch (expectedStage['name'].toString().toLowerCase()) {
            case 'pickup created':
              noteTexts.add(l10n.pickupHasBeenCreatedDesc);
              break;
            case 'driverassigned':
              noteTexts.add(l10n.pickupAssignedToDriverDesc.replaceAll('{driver}', 'man1'));
              break;
            case 'pickedup':
              noteTexts.add(l10n.orderPickedUpByCourierDesc.replaceAll('{driver}', 'man1'));
              break;
            case 'completed':
              noteTexts.add(l10n.allOrdersFromPickupInStockDesc);
              break;
            default:
              // Fallback to API notes if stage name doesn't match
              noteTexts = apiStage.stageNotes.map((note) => note.text).toList();
          }
        }
        
        return _buildTimelineItem(
          title: displayName,
          time: displayTime,
          date: displayDate,
          status: status,
          isFirst: isFirst,
          isLast: isLast,
          icon: expectedStage['icon'] as IconData,
          iconBgColor: expectedStage['color'] as Color,
          stageNotes: noteTexts,
        );
      }).toList(),
    );
  }
  
  String _getDisplayStageName(String stageName) {
    final l10n = AppLocalizations.of(context);
    switch (stageName.toLowerCase()) {
      case 'pickup created':
        return l10n.pickupCreated;
      case 'driverassigned':
        return l10n.driverAssigned;
      case 'pickedup':
        return l10n.itemsPickedUp;
      case 'completed':
        return l10n.completed;
      default:
        return stageName;
    }
  }
  
  Widget _buildTimelineItem({
    required String title,
    required String time,
    required String date,
    required String status,
    required bool isFirst,
    required bool isLast,
    required IconData icon,
    required Color iconBgColor,
    required List<String> stageNotes,
  }) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    // Orange theme colors
    Color statusColor;
    Color statusBgColor;
    Color timelineColor;
    Color cardBorderColor;
    
    final l10n = AppLocalizations.of(context);
    final isCompleted = status == l10n.completed;
    final isInProgress = status == l10n.inProgress;
    
    if (isCompleted) {
      statusColor = const Color(0xFFFF6B35);
      statusBgColor = const Color(0xFFFF6B35).withOpacity(0.1);
      timelineColor = const Color(0xFFFF6B35);
      cardBorderColor = const Color(0xFFFF6B35).withOpacity(0.3);
    } else if (isInProgress) {
      statusColor = const Color(0xFFFF6B35);
      statusBgColor = const Color(0xFFFF6B35).withOpacity(0.1);
      timelineColor = const Color(0xFFFF6B35);
      cardBorderColor = const Color(0xFFFF6B35).withOpacity(0.3);
    } else {
      statusColor = Colors.grey.shade600;
      statusBgColor = Colors.grey.shade100;
      timelineColor = Colors.grey.shade300;
      cardBorderColor = Colors.grey.shade200;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Enhanced Timeline Indicator
        Column(
          children: [
            Container(
                width: 48,
                height: 48,
              decoration: BoxDecoration(
                  gradient: isCompleted || isInProgress
                      ? const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFE55A2B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isCompleted || isInProgress 
                      ? null 
                      : Colors.grey.shade300,
                shape: BoxShape.circle,
                  boxShadow: isCompleted || isInProgress
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
              ),
              child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                  color: Colors.white,
                          size: 28,
                        )
                      : Icon(
                          icon,
                          color: isCompleted || isInProgress
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: 24,
                ),
              ),
            ),
            if (!isLast)
              Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFE55A2B)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: isCompleted ? null : timelineColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
              ),
          ],
        ),
          SizedBox(width: spacing),
          // Enhanced Content Card
        Expanded(
            child: Container(
              padding: EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: cardBorderColor,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                title,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 17,
                              tablet: 19,
                              desktop: 21,
                            ),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (status == 'In Progress')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFF6B35).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).current,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 11,
                                tablet: 12,
                                desktop: 13,
                              ),
                              color: const Color(0xFFFF6B35),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (date != '--/--/----') ...[
              Row(
                children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: const Color(0xFFFF6B35),
                        ),
                        const SizedBox(width: 6),
                  Text(
                          '$date, $time',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 13,
                              tablet: 14,
                              desktop: 15,
                            ),
                            color: const Color(0xFFFF6B35),
                            fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
                    const SizedBox(height: 8),
                  ],
              // Display stage notes if available
              if (stageNotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                    ...stageNotes.map((note) => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                  child: Text(
                    note,
                    style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 12,
                            tablet: 13,
                            desktop: 14,
                          ),
                          color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )),
              ],
                  const SizedBox(height: 8),
                  // Status Badge
        Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusBgColor,
            borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                      ),
          ),
          child: Text(
            status,
            style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
              color: statusColor,
                        fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupDetailsTab() {
    // Use the existing PickupDetailsScreen but not as a Scaffold
    final repository = ref.read(pickupRepositoryProvider);
    return PickupDetailsContent(
      pickup: widget.pickup,
      repository: repository,
    );
  }

  Widget _buildOrdersPickedTab() {
    // Watch the picked up orders from the API
    final pickedUpOrdersAsync = ref.watch(pickedUpOrdersProvider(widget.pickup.pickupNumber));
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Modern Header with Orange Theme
          Container(
            padding: EdgeInsets.all(spacing * 1.5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFE55A2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(spacing * 0.75),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(borderRadius * 0.5),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).ordersPickedUp,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 20,
                                tablet: 22,
                                desktop: 24,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context).trackYourPickedUpOrders,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing),
                // Modern search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).searchByOrderIdCustomerOrLocation,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: const Color(0xFFFF6B35),
                        size: 24,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: spacing,
                        vertical: spacing * 0.75,
                      ),
                    ),
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
          
          // Orders list from API
          Expanded(
            child: pickedUpOrdersAsync.when(
              data: (orders) {
                // Filter orders based on search query
                final filteredOrders = orders.where((order) {
                  final query = _searchQuery.toLowerCase();
                  if (query.isEmpty) return true;
                  
                  return order.orderNumber.toLowerCase().contains(query) ||
                      order.orderCustomer.fullName.toLowerCase().contains(query) ||
                      order.orderCustomer.address.toLowerCase().contains(query);
                }).toList();
                
                if (filteredOrders.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: EdgeInsets.all(spacing),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildModernOrderCard(order, spacing, borderRadius);
                  },
                );
              },
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for the new design
  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined,
              size: 64,
              color: const Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty 
                ? l10n.noOrdersMatchingQuery.replaceFirst('{query}', _searchQuery)
                : l10n.noOrdersPickedUpYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xff2F2F2F),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? l10n.adjustSearchTerms
                : l10n.ordersWillAppearAfterPickup,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          CircularProgressIndicator(
            color: const Color(0xFFFF6B35),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.loadingOrders,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
            l10n.failedToLoadOrders,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xff2F2F2F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
            '${l10n.error}: $error',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(pickedUpOrdersProvider(widget.pickup.pickupNumber));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  

  // Modern Order Card with Orange Theme
  Widget _buildModernOrderCard(PickedUpOrder order, double spacing, double borderRadius) {
    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B35).withOpacity(0.1),
                  const Color(0xFFFF6B35).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
            child: Row(
              children: [
                // Order icon
                Container(
                  padding: EdgeInsets.all(spacing * 0.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(borderRadius * 0.5),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: spacing * 0.67),
                // Order number
                Expanded(
                  child: Text(
                    '${AppLocalizations.of(context).order} #${order.orderNumber}',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2F2F2F),
                    ),
                  ),
                ),
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing * 0.67,
                    vertical: spacing * 0.33,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(borderRadius * 0.5),
                    border: Border.all(
                      color: _getStatusColor(order.orderStatus).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getStatusDisplayName(order.orderStatus),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 12,
                        tablet: 13,
                        desktop: 14,
                      ),
                      color: _getStatusColor(order.orderStatus),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(spacing),
            child: Column(
              children: [
                // Customer info
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: AppLocalizations.of(context).customer,
                  value: order.orderCustomer.fullName,
                  iconColor: const Color(0xFFFF6B35),
                ),
                SizedBox(height: spacing * 0.5),
                
                // Address
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: AppLocalizations.of(context).address,
                  value: order.orderCustomer.address,
                  iconColor: const Color(0xFFFF6B35),
                ),
                SizedBox(height: spacing * 0.5),
                
                // Phone
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: AppLocalizations.of(context).phone,
                  value: order.orderCustomer.phoneNumber,
                  iconColor: const Color(0xFFFF6B35),
                ),
                SizedBox(height: spacing * 0.5),
                
                // Product description
                if (order.orderShipping.productDescription.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.inventory_2_outlined,
                    label: AppLocalizations.of(context).product,
                    value: order.orderShipping.productDescription,
                    iconColor: const Color(0xFFFF6B35),
                  ),
                  SizedBox(height: spacing * 0.5),
                ],
                
                // Divider
                Container(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                SizedBox(height: spacing * 0.5),
                
                // Fee information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing * 0.5,
                            vertical: spacing * 0.25,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(borderRadius * 0.3),
                          ),
                          child: Text(
                            AppLocalizations.of(context).egp,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 12,
                                tablet: 13,
                                desktop: 14,
                              ),
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing * 0.33),
                        Text(
                          '${order.orderFees.toStringAsFixed(0)}.00',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff2F2F2F),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      order.orderShipping.amountType,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                  ),
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                  color: const Color(0xff2F2F2F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'picked':
      case 'pickedup':
        return Colors.orange;
      case 'in stock':
      case 'instock':
        return Colors.blue;
      case 'heading to customer':
      case 'headingtocustomer':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'picked':
      case 'pickedup':
        return 'Picked';
      case 'in stock':
      case 'instock':
        return 'In Stock';
      case 'heading to customer':
      case 'headingtocustomer':
        return 'Heading to Customer';
      default:
        return status;
    }
  }
}

// Extract the content part of the PickupDetailsScreen without the Scaffold
class PickupDetailsContent extends StatefulWidget {
  final PickupModel pickup;
  final dynamic repository;

  const PickupDetailsContent({
    super.key,
    required this.pickup,
    required this.repository,
  });

  @override
  State<PickupDetailsContent> createState() => _PickupDetailsContentState();
}

class _PickupDetailsContentState extends State<PickupDetailsContent> {
  late int _driverRating;
  late int _serviceRating;
  bool _hasSubmittedRatings = false;

  @override
  void initState() {
    super.initState();
    // Initialize ratings from pickup data
    _driverRating = widget.pickup.driverRating ?? 0;
    _serviceRating = widget.pickup.pickupRating ?? 0;
    _hasSubmittedRatings = _driverRating > 0 || _serviceRating > 0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isPickedUp = widget.pickup.status == AppLocalizations.of(context).pickedUp;
    final String formattedDate = '${widget.pickup.pickupDate.day}/${widget.pickup.pickupDate.month}/${widget.pickup.pickupDate.year}';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Professional Status Card with Orange Theme
            _buildProfessionalStatusCard(isPickedUp),
            const SizedBox(height: 16),

            // Enhanced Pickup Details Card
            _buildEnhancedPickupDetailsCard(formattedDate, isPickedUp),
            const SizedBox(height: 16),
            
            // Professional Driver Details Section
            _buildProfessionalDriverSection(isPickedUp),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalStatusCard(bool isPickedUp) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return Container(
            width: double.infinity,
      padding: EdgeInsets.all(spacing * 1.5),
            decoration: BoxDecoration(
        gradient: isPickedUp 
            ? const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFE55A2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (isPickedUp ? const Color(0xFF4CAF50) : const Color(0xFFFF6B35)).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
            ),
            child: Row(
              children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
                  isPickedUp ? Icons.check_circle : Icons.local_shipping_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pickup.status,
                      style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                        fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                      ),
                    ),
                const SizedBox(height: 4),
                    Text(
                  isPickedUp ? AppLocalizations.of(context).yourPickupHasBeenCompletedSuccessfully : 'Your pickup is scheduled and ready',
                      style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '#${widget.pickup.pickupNumber}',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
                fontWeight: FontWeight.bold,
                color: isPickedUp ? const Color(0xFF4CAF50) : const Color(0xFFFF6B35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPickupDetailsCard(String formattedDate, bool isPickedUp) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header with Orange Theme
          Container(
            padding: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFE55A2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: spacing),
                Text(
                  AppLocalizations.of(context).pickupDetails,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Pickup Information Section
          _buildEnhancedSubsectionHeader(AppLocalizations.of(context).pickupInformation),
          _buildEnhancedDetailItem(AppLocalizations.of(context).pickupId, '#${widget.pickup.pickupNumber}', Icons.tag),
          _buildEnhancedDetailItem(AppLocalizations.of(context).pickupType, AppLocalizations.of(context).normal, Icons.category),
          _buildEnhancedDetailItem(AppLocalizations.of(context).numberOfOrders, '${widget.pickup.numberOfOrders}', Icons.shopping_bag),
          // Pickup Fees - Prominently displayed
          _buildPickupFeesCard(),
          _buildEnhancedDetailItem(AppLocalizations.of(context).scheduledDate, formattedDate, Icons.calendar_today),
          _buildEnhancedDetailItem(AppLocalizations.of(context).status, widget.pickup.status, Icons.info),
          _buildDivider(),

          // Address & Contact Section
          _buildEnhancedSubsectionHeader(AppLocalizations.of(context).addressAndContact),
          _buildEnhancedDetailItem(AppLocalizations.of(context).address, widget.pickup.address, Icons.location_on),
          _buildEnhancedDetailItem(AppLocalizations.of(context).contactNumber, widget.pickup.contactNumber, Icons.phone),
          
          // Special Requirements Section (if applicable)
          if (widget.pickup.isFragileItem || widget.pickup.isLargeItem) ...[
            _buildDivider(),
            _buildEnhancedSubsectionHeader(AppLocalizations.of(context).specialRequirements),
            if (widget.pickup.isFragileItem)
              _buildEnhancedDetailItem(
                AppLocalizations.of(context).fragileItem, 
                AppLocalizations.of(context).fragileItemDescription,
                Icons.warning_amber_rounded,
                iconColor: Colors.orange,
              ),
            if (widget.pickup.isLargeItem)
              _buildEnhancedDetailItem(
                AppLocalizations.of(context).largeItem, 
                AppLocalizations.of(context).largeItemDescription,
                Icons.local_shipping,
                iconColor: Colors.blue,
              ),
          ],

          // Notes Section (if applicable)
          if (widget.pickup.notes != null && widget.pickup.notes!.isNotEmpty) ...[
            _buildDivider(),
            _buildEnhancedSubsectionHeader(AppLocalizations.of(context).notes),
            _buildEnhancedDetailItem(AppLocalizations.of(context).specialInstructions, widget.pickup.notes!, Icons.note),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedSubsectionHeader(String title) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing, spacing, spacing, spacing / 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C3E50),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPickupFeesCard() {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing, vertical: 8),
      padding: EdgeInsets.all(spacing * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B35).withOpacity(0.1),
            const Color(0xFFFF6B35).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.attach_money,
              color: Color(0xFFFF6B35),
              size: 28,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).pickupFees,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.pickup.pickupFees.toStringAsFixed(0)} EGP',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 24,
                      tablet: 28,
                      desktop: 32,
                    ),
                    color: const Color(0xFFFF6B35),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDetailItem(String label, String value, IconData icon, {Color? iconColor}) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final isPhoneIcon = icon == Icons.phone;
    final isPickupId = label == 'Pickup ID';
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing, vertical: 4),
      padding: EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phone icon without background and clickable
          if (isPhoneIcon)
            GestureDetector(
              onTap: () => _makePhoneCall(value),
              child: Icon(
                icon,
                color: const Color(0xFFFF6B35),
                size: 18,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFFFF6B35)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: iconColor ?? const Color(0xFFFF6B35),
                size: 18,
              ),
            ),
          SizedBox(width: spacing),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            flex: 3,
            child: isPhoneIcon
                ? GestureDetector(
                    onTap: () => _makePhoneCall(value),
            child: Text(
              value,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                        color: const Color(0xFFFF6B35),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                            color: const Color(0xFF2C3E50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isPickupId) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _copyToClipboard(value),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.copy,
                              color: const Color(0xFFFF6B35),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Function to make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch $phoneUri');
    }
  }

  // Function to copy text to clipboard
  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied to clipboard: $text'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey.shade200,
    );
  }

  Widget _buildProfessionalDriverSection(bool isPickedUp) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Driver Header
          Container(
            padding: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFE55A2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
            child: Row(
            children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: spacing),
                Text(
                  AppLocalizations.of(context).driverDetails,
                    style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
            ),
          ),
          
          // Driver Information
          _buildEnhancedDetailItem(AppLocalizations.of(context).driverName, widget.pickup.assignedDriver?.name ?? AppLocalizations.of(context).notAssignedYet, Icons.person),
          _buildEnhancedDetailItem(AppLocalizations.of(context).vehicleType, widget.pickup.assignedDriver?.vehicleType ?? AppLocalizations.of(context).na, Icons.directions_car),
          _buildEnhancedDetailItem(AppLocalizations.of(context).plateNumber, widget.pickup.assignedDriver?.vehiclePlateNumber ?? AppLocalizations.of(context).na, Icons.confirmation_number),
          _buildEnhancedDetailItem(AppLocalizations.of(context).pickedUpOrders, '${widget.pickup.ordersPickedUp.length}', Icons.shopping_bag),
          
          // Rating Section
          _buildEnhancedRatingSection(isPickedUp),
        ],
      ),
    );
  }

  Widget _buildEnhancedRatingSection(bool isPickedUp) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    
    return Container(
      margin: EdgeInsets.all(spacing),
      padding: EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.2),
        ),
      ),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
            AppLocalizations.of(context).rateYourExperience,
                style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          
          // Driver Rating Section
          _buildRatingRow(AppLocalizations.of(context).driver, _driverRating, (rating) {
            if (isPickedUp && !_hasSubmittedRatings) {
              setState(() {
                _driverRating = rating;
              });
            }
          }, isPickedUp && !_hasSubmittedRatings),
          
          if (isPickedUp) const SizedBox(height: 24),
          
          // Service Rating Section
          _buildRatingRow(AppLocalizations.of(context).service, _serviceRating, (rating) {
            if (isPickedUp && !_hasSubmittedRatings) {
              setState(() {
                _serviceRating = rating;
              });
            }
          }, isPickedUp && !_hasSubmittedRatings),
          
          if (isPickedUp && !_hasSubmittedRatings) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
              onPressed: (_driverRating > 0 || _serviceRating > 0) ? () => _submitRating() : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: spacing),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
                child: Text(
                  AppLocalizations.of(context).submitRating,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          
          // Show message if ratings have already been submitted
          if (isPickedUp && _hasSubmittedRatings) ...[
            const SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Thank you for your feedback! Your ratings have been submitted.',
                      style: TextStyle(
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
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
          ],
        ],
      ),
    );
  }

  Widget _buildRatingRow(String title, int rating, Function(int) onRatingChanged, bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        _buildStarRating(
          rating: rating,
          onRatingChanged: onRatingChanged,
          enabled: enabled,
        ),
        if (!enabled) 
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              AppLocalizations.of(context).availableAfterPickupCompletion,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                ),
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  
  Widget _buildStarRating({
    required int rating, 
    required Function(int) onRatingChanged, 
    required bool enabled
  }) {
    return Row(
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: enabled ? () => onRatingChanged(index + 1) : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: index < rating ? const Color(0xFFFFC107) : Colors.grey.shade400,
            size: 28,
          ),
        );
      }),
    );
  }

  /// Submit rating to the API
  Future<void> _submitRating() async {
    try {
      // Submit the rating
      final success = await widget.repository.ratePickup(
        pickupNumber: widget.pickup.pickupNumber,
        driverRating: _driverRating,
        pickupRating: _serviceRating,
      );
      
      if (success) {
        // Mark ratings as submitted
        setState(() {
          _hasSubmittedRatings = true;
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rating submitted successfully'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit rating. Please try again.'),
              backgroundColor: Color(0xFFE53E3E),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    }
  }
} 