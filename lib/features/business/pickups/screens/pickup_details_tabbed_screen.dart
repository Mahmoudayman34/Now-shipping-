import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/pickups/models/pickup_model.dart';
import 'package:now_shipping/features/business/pickups/providers/pickup_provider.dart';
import '../../../../core/utils/responsive_utils.dart';

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

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        appBar: AppBar(
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
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF26A2B9),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF26A2B9),
            labelStyle: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
            ),
            tabs: const [
              Tab(text: 'Tracking'),
              Tab(text: 'Pickup Details'),
              Tab(text: 'Orders Picked'),
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
    
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              color: const Color(0xFF82D0E9).withOpacity(0.2),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: const Color(0xFF26A2B9),
                  size: ResponsiveUtils.getResponsiveIconSize(context),
                ),
                SizedBox(width: spacing),
                Text(
                  'Pickup Status',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF26A2B9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing * 2),
          _buildTrackingTimeline(),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    final pickupStages = widget.pickup.pickupStages;
    
    // Define the expected stages in order
    final expectedStages = [
      {'name': 'Pickup Created', 'icon': Icons.inventory_2_outlined, 'color': const Color(0xFFE57254)},
      {'name': 'driverAssigned', 'icon': Icons.person_outline, 'color': const Color(0xFFEF9A7B)},
      {'name': 'pickedUp', 'icon': Icons.shopping_bag_outlined, 'color': const Color(0xFFFFBE98)},
      {'name': 'completed', 'icon': Icons.check_circle_outline, 'color': const Color(0xFFFFD1B8)},
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
        
        if (stageExists) {
          status = 'Completed';
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
          
          status = previousStageCompleted && index < expectedStages.length - 1 ? 'In Progress' : 'Pending';
        }
        
        // Get display name
        String displayName = _getDisplayStageName(expectedStage['name'] as String);
        
        // Convert stageNotes to list of strings
        List<String> noteTexts = stageExists ? apiStage.stageNotes.map((note) => note.text).toList() : [];
        
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
    switch (stageName.toLowerCase()) {
      case 'pickup created':
        return 'Pickup Created';
      case 'driverassigned':
        return 'Driver Assigned';
      case 'pickedup':
        return 'Items Picked Up';
      case 'completed':
        return 'Completed';
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
    Color statusColor;
    Color statusBgColor;
    
    switch (status) {
      case 'Completed':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.1);
        break;
      case 'In Progress':
        statusColor = const Color(0xFFF89C29);
        statusBgColor = const Color(0xFFF89C29).withOpacity(0.1);
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withOpacity(0.1);
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: status == 'Completed' ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff2F2F2F),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    date == '--/--/----' ? '--' : '$date, $time',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              // Display stage notes if available
              if (stageNotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...stageNotes.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    note,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )),
              ],
              if (!isLast) const SizedBox(height: 30),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusBgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupDetailsTab() {
    // Use the existing PickupDetailsScreen but not as a Scaffold
    return PickupDetailsContent(pickup: widget.pickup);
  }

  Widget _buildOrdersPickedTab() {
    // Watch the picked up orders from the API
    final pickedUpOrdersAsync = ref.watch(pickedUpOrdersProvider(widget.pickup.pickupNumber));
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.all(spacing),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by order ID, customer or location',
              hintStyle: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: const Color(0xFF26A2B9),
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: spacing),
            ),
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined, 
                        size: 48, 
                        color: Colors.grey.shade400
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty 
                            ? 'No orders found matching "$_searchQuery"'
                            : 'No orders picked up yet',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return _buildOrderCard(order);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF26A2B9),
              ),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load orders',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(pickedUpOrdersProvider(widget.pickup.pickupNumber));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A2B9),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildOrderCard(PickedUpOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2F2F2F),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusDisplayName(order.orderStatus),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(order.orderStatus),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  order.orderCustomer.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff2F2F2F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.orderCustomer.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff2F2F2F),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  order.orderCustomer.phoneNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff2F2F2F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'EGP',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${order.orderShipping.amount.toStringAsFixed(0)}.00',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff2F2F2F),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  order.orderShipping.amountType,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            if (order.orderShipping.productDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.orderShipping.productDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff2F2F2F),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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

  const PickupDetailsContent({
    super.key,
    required this.pickup,
  });

  @override
  State<PickupDetailsContent> createState() => _PickupDetailsContentState();
}

class _PickupDetailsContentState extends State<PickupDetailsContent> {
  int _driverRating = 0;
  int _serviceRating = 0;

  @override
  Widget build(BuildContext context) {
    final bool isPickedUp = widget.pickup.status == 'Picked Up';
    final Color statusColor = isPickedUp ? Colors.green : const Color(0xFFF89C29);
    final String formattedDate = '${widget.pickup.pickupDate.day}/${widget.pickup.pickupDate.month}/${widget.pickup.pickupDate.year}';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  isPickedUp ? Icons.check_circle : Icons.local_shipping_outlined,
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pickup.status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      isPickedUp ? 'Your pickup has been completed' : 'Your pickup is scheduled',
                      style: TextStyle(
                        color: statusColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Combined Pickup Details Card
          _buildCombinedPickupDetailsCard(formattedDate, isPickedUp),
            
          // Driver Details Section (New)
          _buildDetailSection(
            'Driver Details',
            [
              _buildDetailItem('Driver Name', widget.pickup.assignedDriver?.name ?? 'Not assigned yet'),
              _buildDetailItem('Vehicle Type', widget.pickup.assignedDriver?.vehicleType ?? 'N/A'),
              _buildDetailItem('Plate', widget.pickup.assignedDriver?.vehiclePlateNumber ?? 'N/A'),
              _buildDetailItem('Picked Up Orders', '${widget.pickup.ordersPickedUp.length}'),
              _buildRatingItem(isPickedUp),
            ],
            icon: Icons.person_outline,
            iconColor: const Color(0xFF26A2B9),
          ),
        ],
      ),
    );
  }

  // New method to build the combined pickup details card
  Widget _buildCombinedPickupDetailsCard(String formattedDate, bool isPickedUp) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
          // Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: Color(0xFF26A2B9), size: 22),
                SizedBox(width: 8),
                Text(
                  'Pickup Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff2F2F2F),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Pickup Information Section
          _buildSubsectionHeader('Pickup Information'),
          _buildDetailItem('Pickup ID', '#${widget.pickup.pickupNumber}'),
          _buildDetailItem('Pickup Type', 'Normal'),
          _buildDetailItem('Number of Orders', '${widget.pickup.numberOfOrders}'),
          _buildDetailItem('Scheduled Date', formattedDate),
          _buildDetailItem('Status', widget.pickup.status),
          const Divider(height: 1),

          // Address & Contact Section
          _buildSubsectionHeader('Address & Contact'),
          _buildDetailItem('Address', widget.pickup.address),
          _buildDetailItem('Contact Number', widget.pickup.contactNumber),
          
          // Special Requirements Section (if applicable)
          if (widget.pickup.isFragileItem || widget.pickup.isLargeItem) ...[
            const Divider(height: 1),
            _buildSubsectionHeader('Special Requirements'),
            if (widget.pickup.isFragileItem)
              _buildDetailItem(
                'Fragile Item', 
                'This pickup contains fragile items that require special handling',
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.orange,
              ),
            if (widget.pickup.isLargeItem)
              _buildDetailItem(
                'Large Item', 
                'This pickup contains large items that may require a larger vehicle',
                icon: Icons.local_shipping,
                iconColor: Colors.blue,
              ),
          ],

          // Notes Section (if applicable)
          if (widget.pickup.notes != null && widget.pickup.notes!.isNotEmpty) ...[
            const Divider(height: 1),
            _buildSubsectionHeader('Notes'),
            _buildDetailItem('Special Instructions', widget.pickup.notes!),
          ],
        ],
      ),
    );
  }

  Widget _buildSubsectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items, {IconData? icon, Color? iconColor}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: iconColor, size: 22),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff2F2F2F),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff2F2F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRatingItem(bool isPickedUp) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          // Driver Rating Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              _buildStarRating(
                rating: _driverRating,
                onRatingChanged: (rating) {
                  if (isPickedUp) {
                    setState(() {
                      _driverRating = rating;
                    });
                  }
                },
                enabled: isPickedUp,
              ),
              if (!isPickedUp) 
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Text(
                    'Available after pickup completion',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
          
          // Add some spacing between driver and service ratings
          if (isPickedUp) const SizedBox(height: 24),
          
          // Service Rating Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              _buildStarRating(
                rating: _serviceRating,
                onRatingChanged: (rating) {
                  if (isPickedUp) {
                    setState(() {
                      _serviceRating = rating;
                    });
                  }
                },
                enabled: isPickedUp,
              ),
              if (!isPickedUp) 
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                    'Available after pickup completion',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
          
          if (isPickedUp) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_driverRating > 0 || _serviceRating > 0) ? () {
                // Submit rating logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rating submitted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A2B9),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: const Text('Submit Rating'),
            ),
          ],
        ],
      ),
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
} 